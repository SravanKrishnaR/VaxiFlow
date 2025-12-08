process PROTPARAM {
  publishDir "Results/PROTPARAM", mode: "copy", createDirs: true

  errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

  input:
  path TMR_sequence
  path PROTPARAM_script
  path deepthmmm_csv

  output:
  path "results.txt"

  script:
  """
  if [[ '${params.mode}' == 'filtered' && ! -s "${TMR_sequence}" ]]; then
    echo "PROTPARAM: Input file TMR_sequence is empty."
    exit 100
fi

  python ${PROTPARAM_script} -p ${TMR_sequence} > results.txt
  """
}
