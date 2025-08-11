process SIGNALP {
    container 'sravankrishna47/signalp-fast'

    publishDir "Results/signalp_results", mode: "copy"

    input:
    path non_allergen_sequences

    output:
    path "signalp/processed_entries.fasta", emit: signalp_sequences

    stub:
    """
    mkdir -p signalp
    echo '>stub_signalp\nMVKELRESTK' > signalp/processed_entries.fasta
    """

    script:
    """
    mkdir -p signalp
    signalp6 --fastafile ${non_allergen_sequences} --organism other --output_dir signalp --format txt --mode fast
    """
}
