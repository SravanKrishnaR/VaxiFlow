process ALGPRED {
  container 'sravankrishna47/algpred2:latest'

  errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

  publishDir "Results/ALGPRED", mode: "copy"

  input:
  path Non_human_proteins
  path human_homologs_csv

  output:
  path "non_allergen_sequences.fasta", emit: non_allergen_sequences
  path "ALGPRED.ids", emit: ALGPRED_ids
  path "algpred.csv", emit: algpred_csv
  
  stub:
  """
  echo '>stub_nonallergen\nGAVLILALVVL' > non_allergen_sequences.fasta
  """

  script:
  """
  if [[ '${params.mode}' == 'filtered' && ! -s "${Non_human_proteins}" ]]; then
    echo "ALGPRED: Input file Non_human_proteins is empty."
    exit 100
fi 


 # Run AlgPred2
  algpred2 -i ${Non_human_proteins} -o result_allergen.csv

  # Extract allergen IDs from CSV (first column, skip header, strip quotes/whitespace)
  tr -d '\\r' < result_allergen.csv \\
    | awk -F',' 'NR>1 { gsub(/"/,"",\$1); gsub(/^[ \t]+|[ \t]+\$/,"",\$1); print \$1 }' > allergen_ids.txt

  # Filter non-allergen sequences (remove any whose ID matches allergen_ids.txt)
  awk 'BEGIN{ while(getline < "allergen_ids.txt") ids[\$1]=1 }
       /^>/ { split(\$1,a," "); id = substr(a[1],2); skip = (id in ids) }
       { if(!skip) print }
  ' ${Non_human_proteins} > non_allergen_sequences.fasta

  # Extract IDs of final non-allergen proteins
  awk '/^>/ { split(\$1,a," "); print substr(a[1],2) }' non_allergen_sequences.fasta > ALGPRED.ids

  # Ensure CSV line endings are clean
  tr -d '\\r' < ${human_homologs_csv} > human_homologs.tmp && mv human_homologs.tmp ${human_homologs_csv}

  # Merge with previous CSV and add ALGPRED column
  awk 'BEGIN {
    FS=OFS=","
    casefile = ARGV[1]
    n = split(casefile, parts, "/")
    base = parts[n]
    sub(/\\.[^.]*\$/, "", base)
    CASENAME = base
}
FILENAME == casefile {
    case_count++
    dict[\$1]=1
    next
}
FNR==1 {
    print \$0, CASENAME
    next
}
{
    print \$0, (case_count ? (\$1 in dict ? 1 : 0) : 0)
}' ALGPRED.ids ${human_homologs_csv} > algpred.csv

  """
}
