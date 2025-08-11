process DEEPLOCPRO {
    container 'sravankrishna47/deeplocpro'

    publishDir "Results/DEEPLOCPRO", mode: "copy"

    input:
    path signalp_sequences

    output:
    path "outer_membrane.fasta", emit: outermembrane_sequences

    stub:
    """
    echo '>stub_om\nGAVLLLLAVVV' > outer_membrane.fasta
    """

    script:
    """
    export TORCH_HOME=\$PWD/.cache

    sed 's/\\*//g' ${signalp_sequences} > cleaned_input.fasta
    deeplocpro -f cleaned_input.fasta -o deeploc_output -g negative
    mv deeploc_output/results_*.csv deeploc_results.csv
    awk -F',' '\$3 == "Outer Membrane" || \$3 == "Extracellular" {print \$2}' deeploc_results.csv > ids.txt
    seqkit grep -f ids.txt ${signalp_sequences} > outer_membrane.fasta
    """
}
