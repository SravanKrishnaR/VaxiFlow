process TOXINPRED {
    container 'sravankrishna47/toxinpred3:latest'

    publishDir "Results/TOXINPRED", mode: "copy"

    input:
    path outermembrane_sequences

    output:
    path "non_toxins.fasta", emit: non_toxins

    stub:
    """
    echo '>stub_nontox\nMVKELTNVLT' > non_toxins.fasta
    """

    script:
    """
    toxinpred3 -i ${outermembrane_sequences}
    awk -F ',' 'NR > 1 && \$6 == "Non-Toxin" {print \$1}' outfile.csv > seq_id.txt
    seqkit grep -f seq_id.txt ${outermembrane_sequences} > non_toxins.fasta
    """
}
