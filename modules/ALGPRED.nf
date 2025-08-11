process ALGPRED {
  container 'sravankrishna47/algpred2:latest'

  publishDir "Results/ALGPRED", mode: "copy"

  input:
  path Non_human_proteins

  output:
  path "non_allergen_sequences.fasta", emit: non_allergen_sequences

  stub:
  """
  echo '>stub_nonallergen\nGAVLILALVVL' > non_allergen_sequences.fasta
  """

  script:
  """
  algpred2 -i ${Non_human_proteins} -o result_allergen.fasta
  cut -d',' -f1 result_allergen.fasta > allergen_ids.txt
  seqkit grep -v -f allergen_ids.txt ${Non_human_proteins} > non_allergen_sequences.fasta
  """
}
