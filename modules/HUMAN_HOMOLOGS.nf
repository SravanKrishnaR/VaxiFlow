process HUMAN_HOMOLOGS {
  publishDir "Results/HUMAN_HOMOLOGS", mode: "copy"

  input:
  path virulent_proteins
  path human_db
  path vfdb_csv
  val ready

  output:
  path "Non_human_proteins.fasta", emit: Non_human_proteins
  path "HUMAN_HOMOLOGS.ids", emit: HUMAN_HOMOLOGS_ids
  path "human_homologs.csv", emit: human_homologs_csv
  val true, emit: ready

  stub:
  """
  echo '>stub_nonhuman\nMTEITAAMVKEL' > Non_human_proteins.fasta
  cp ${vfdb_csv} human_homologs.csv
  """

  script:
  """
  # Run diamond to find human homologs
  diamond blastp --query ${virulent_proteins} --db ${human_db} --out human_hits.tsv --outfmt 6

  # Extract hit IDs (proteins that are homologous to human)
  awk '\$11 <= 1e-5 && \$3 >= 30 && \$4 >= 50' human_hits.tsv | cut -f1 | sort | uniq > human_homolog_ids.txt

  # Filter out human homologs -> keep only NON-humans in fasta
  seqkit grep -v -f human_homolog_ids.txt ${virulent_proteins} > Non_human_proteins.fasta

  # Make NON-homolog list for CSV
  seqkit seq -n Non_human_proteins.fasta | awk '{print \$1}' > HUMAN_HOMOLOGS.ids

  # Ensure CSV line endings are clean
  tr -d '\\r' < ${vfdb_csv} > vfdb.tmp && mv vfdb.tmp ${vfdb_csv}

  # Add HUMAN_HOMOLOGS column to vfdb_csv
  awk 'BEGIN{FS=OFS=","}
     NR==FNR { ids[\$1]=1; next }
     FNR==1  { print \$0 ",HUMAN_HOMOLOGS"; next }
     { id=\$1; print \$0 "," (id in ids ? 1 : 0) }
  ' HUMAN_HOMOLOGS.ids ${vfdb_csv} > human_homologs.csv
  """
}
