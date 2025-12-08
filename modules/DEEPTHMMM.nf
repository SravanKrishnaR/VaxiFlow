process DEEPTHMMM {
    publishDir "Results/DEEPTHMMM", mode: "copy"

    errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

    input:
    path non_toxins
    path toxinpred_csv

    output:
    path "biolib_results/*", emit: gff3
    path non_toxins, emit: non_toxins
    path "toxinpred.csv", emit: toxinpred_csv

    stub:
    """
    mkdir -p biolib_results
    echo '##gff-version 3' > biolib_results/TMRs.gff3
    """

    script:
    """
    if [[ '${params.mode}' == 'filtered' && ! -s "${non_toxins}" ]]; then
    echo "DEEPTHMMM: Input file non_toxins is empty."
    exit 100
fi

    biolib run --local 'DTU/DeepTMHMM:1.0.24' --fasta ${non_toxins}
    """
}
