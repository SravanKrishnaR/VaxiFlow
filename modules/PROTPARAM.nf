process PROTPARAM {

  container 'sravankrishna47/protparam:latest'
  errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

  publishDir "${params.outdir}/PROTPARAM/${name}", mode: "copy"

  input:
  tuple val(name), path(PHOBIUS_fasta), path(phobius_csv)
  path PROTPARAM_script

  output:
  tuple val(name), path(PHOBIUS_fasta), path(phobius_csv), path("*_results.txt"), emit: PROTPARAM_out

  script:
  """
  if [[ '${params.mode}' == 'filtered' && ! -s "${PHOBIUS_fasta}" ]]; then
    echo "PROTPARAM: Input file PHOBIUS_fasta is empty."
    exit 100
fi

  python ${PROTPARAM_script} -p ${PHOBIUS_fasta} > ${name}_results.txt
  """
}
