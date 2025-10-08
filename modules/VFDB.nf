process VFDB {
  publishDir "Results/VFDB", mode: 'copy'

  input:
  path protein_sequences
  path VFDB_db
  path proteome_csv
  val ready
 
  output:
  path "virulent_proteins.fasta", emit: virulent_proteins
  path "vfdb.ids", emit: vfdb_ids
  path "vfdb.csv", emit: vfdb_csv
  val true, emit: ready

  stub:
  """
  echo '>stub_protein\nMVLSPADKTN' > virulent_proteins.fasta
  """

  script:
  """
  diamond blastp --query ${protein_sequences} --db ${VFDB_db} --out virulence_hits.tsv --outfmt 6
  awk '\$11 <= 1e-5 && \$3 >= 30 && \$4 >= 50' virulence_hits.tsv | cut -f1 | sort | uniq > virulence_ids.txt
  seqkit grep -f virulence_ids.txt ${protein_sequences} > virulent_proteins.fasta

  awk '/^>/ {sub(/^>/,""); print \$1}' virulent_proteins.fasta > VFDB.ids

  # Ensure proteome_csv has UNIX line endings (avoid \r problems)
  tr -d '\r' < ${proteome_csv} > proteome.csv.tmp && mv proteome.csv.tmp ${proteome_csv}

  # Build vfdb.csv by comparing IDs (robust AWK: first file -> ids list, second -> master CSV)
  awk 'BEGIN{FS=OFS=","}
  NR==FNR { ids[\$1]=1; next }
  FNR==1 { print \$0 ",VFDB"; next }
  { id=\$1; print id, (id in ids ? 1 : 0) }
  ' VFDB.ids ${proteome_csv} > vfdb.csv
  """
}
