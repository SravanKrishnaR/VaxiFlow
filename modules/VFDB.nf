process VFDB {
  container 'sravankrishna47/homologyfilter:latest'

  publishDir "Results/VFDB", mode: 'copy'

  input:
  path protein_sequences
  path proteome_csv
 
  output:
  path "virulent_proteins.fasta", emit: virulent_proteins
  path "vfdb.ids", emit: vfdb_ids
  path "vfdb.csv", emit: vfdb_csv

  stub:
  """
  echo '>stub_protein\nMVLSPADKTN' > virulent_proteins.fasta
  """

  script:
  """
  diamond blastp --query ${protein_sequences} --db /app/VFDB_db.dmnd --out virulence_hits.tsv --outfmt 6
  awk '\$11 <= 1e-5 && \$3 >= 30 && \$4 >= 50' virulence_hits.tsv | cut -f1 | sort | uniq > virulence_ids.txt
  seqkit grep -f virulence_ids.txt ${protein_sequences} > virulent_proteins.fasta

  awk '/^>/ {sub(/^>/,""); print \$1}' virulent_proteins.fasta > vfdb.ids

  # Ensure proteome_csv has UNIX line endings (avoid \r problems)
  tr -d '\r' < ${proteome_csv} > proteome.csv.tmp && mv proteome.csv.tmp ${proteome_csv}

  # Build vfdb.csv by comparing IDs (robust AWK: first file -> ids list, second -> master CSV)
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
}' VFDB.ids ${proteome_csv} > vfdb.csv
  """
}
