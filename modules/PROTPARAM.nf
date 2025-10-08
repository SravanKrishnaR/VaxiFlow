process PROTPARAM {
  publishDir "Results/PROTPARAM", mode: "copy", createDirs: true

  input:
  path TMR_sequence
  path PROTPARAM_script
  val ready

  output:
  path "results.txt"
  val true, emit: ready

  script:
  """
  python ${PROTPARAM_script} -p ${TMR_sequence} > results.txt
  """
}
