process DEEPTHMMM {
    publishDir "Results/DEEPTHMMM", mode: "copy"

    input:
    path non_toxins
    val ready

    output:
    path "biolib_results/*", emit: gff3
    path non_toxins, emit: non_toxins
    val true, emit: ready

    stub:
    """
    mkdir -p biolib_results
    echo '##gff-version 3' > biolib_results/TMRs.gff3
    """

    script:
    """
    biolib run --local 'DTU/DeepTMHMM:1.0.24' --fasta ${non_toxins}
    """
}
