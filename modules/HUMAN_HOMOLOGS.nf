process HUMAN_HOMOLOGS {
  publishDir "Results/HUMAN_HOMOLOGS", mode: "copy"

  input:
  path virulent_proteins
  path human_db

  output:
  path "Non_human_proteins.fasta", emit: Non_human_proteins

  stub:
  """
  echo '>stub_nonhuman\nMTEITAAMVKEL' > Non_human_proteins.fasta
  """

  script:
  """
  diamond blastp --query ${virulent_proteins} --db ${human_db} --out human_hits.tsv --outfmt 6
  awk '\$11 <= 1e-5 && \$3 >= 30 && \$4 >= 50' human_hits.tsv | cut -f1 | sort | uniq > human_homolog_ids.txt
  seqkit grep -v -f human_homolog_ids.txt ${virulent_proteins} > Non_human_proteins.fasta
  """
}
