process DEEPTHMMM_2 {
    container 'staphb/seqkit:latest'

    publishDir "Results/DEEPTHMMM", mode: "copy"

    input:
    path gff3
    path non_toxins
    path toxinpred_csv

    output:
    path "TMR_sequences.fasta", emit: TMR_sequence
    path "DEEPTHMMM.ids", emit: DEEPTHMMM_ids
    path "deepthmmm.csv", emit: deepthmmm_csv

    stub:
    """
    echo '>stub_tmr\nMSTAVLLLLAV' > TMR_sequences.fasta
    echo 'PROTEOME_IDS,VFDB,HUMAN_HOMOLOGS,ALGPRED,SIGNALP,DEEPLOCPRO,TOXINPRED,DEEPTHMMM' > deepthmmm.csv
    echo 'stub_tmr,1,0,1,1,1,1,1' >> deepthmmm.csv
    """

    script:
    """
    # Extract IDs of sequences with transmembrane regions
    awk '/^ *# / {
        split(\$0, a, " ");
        seq = a[2];
        getline;
        if (\$7 == "1" || \$7 == "0")
            print seq
    }' ${gff3} > tmrs_ids.txt

    # Filter FASTA sequences
    seqkit grep -f tmrs_ids.txt ${non_toxins} > TMR_sequences.fasta
    seqkit seq -n TMR_sequences.fasta | awk '{print \$1}' | tr -d '\r' > DEEPTHMMM.ids

    # Ensure clean line endings
    tr -d '\\r' < ${toxinpred_csv} > tox.tmp && mv tox.tmp ${toxinpred_csv}

    # Extend CSV: 1 = has TMR, 0 = no TMR
    awk 'BEGIN {
    FS=OFS=","
    casefile = ARGV[1]
    n = split(casefile, parts, "/")
    base = parts[n]
    sub(/\\.[^.]*\$/, "", base)
    CASENAME = base
}
FILENAME == casefile {
    case_count++
    dict[\$1]=1
    next
}
FNR==1 {
    print \$0, CASENAME
    next
}
{
    print \$0, (case_count ? (\$1 in dict ? 1 : 0) : 0)
}' DEEPTHMMM.ids ${toxinpred_csv} > deepthmmm.csv
    """
}
