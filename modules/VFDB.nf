process VFDB {
  publishDir "Results/VFDB", mode: 'copy'

  input:
  path protein_sequences
  path VFDB_db

  output:
  path "virulent_proteins.fasta", emit: virulent_proteins

  stub:
  """
  echo '>stub_protein\nMVLSPADKTN' > virulent_proteins.fasta
  """

  script:
  """
  diamond blastp --query ${protein_sequences} --db ${VFDB_db} --out virulence_hits.tsv --outfmt 6
  awk '\$11 <= 1e-5 && \$3 >= 30 && \$4 >= 50' virulence_hits.tsv | cut -f1 | sort | uniq > virulence_ids.txt
  seqkit grep -v -f virulence_ids.txt ${protein_sequences} > virulent_proteins.fasta
  """
}
