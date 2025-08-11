process DEEPTHMMM_2 {
    publishDir "Results/DEEPTHMMM", mode: "copy"

    input:
    path gff3
    path non_toxins

    output:
    path "TMR_sequences.fasta", emit: TMR_sequence

    stub:
    """
    echo '>stub_tmr\nMSTAVLLLLAV' > TMR_sequences.fasta
    """

    script:
    """
    awk '/^ *# / {
    split(\$0, a, " ");
    seq = a[2];
    getline;
    if (\$7 == "1" || \$7 == "0")
        print seq
    }' TMRs.gff3 > tmrs_ids.txt

    seqkit grep -f tmrs_ids.txt non_toxins.fasta > TMR_sequences.fasta
    """
}
