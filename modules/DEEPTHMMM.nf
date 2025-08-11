process DEEPTHMMM {
    container 'gnick18/deepthmmm:latest'

    publishDir "Results/DEEPTHMMM", mode: "copy"

    input:
    path non_toxins

    output:
    path "biolib_results/*", emit: gff3
    path non_toxins, emit: non_toxins

    stub:
    """
    mkdir -p biolib_results
    echo '##gff-version 3' > biolib_results/TMRs.gff3
    """

    script:
    """
    mkdir -p biolib_results
    XDG_CACHE_HOME="\$PWD/.cache" \
    biolib run DTU/DeepTMHMM --fasta ${non_toxins}
    """
}
