process TOXINPRED {
    container 'sravankrishna47/toxinpred3:latest'

    errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

    publishDir "Results/TOXINPRED", mode: "copy"

    input:
    path outermembrane_sequences
    path deeplocpro_csv

    output:
    path "non_toxins.fasta", emit: non_toxins
    path "TOXINPRED.ids", emit: TOXINPRED_ids
    path "toxinpred.csv", emit: toxinpred_csv

    stub:
    """
    echo '>stub_nontox\nMVKELTNVLT' > non_toxins.fasta
    cp ${deeplocpro_csv} toxinpred.csv
    """

    script:
    """
    if [[ '${params.mode}' == 'filtered' && ! -s "${outermembrane_sequences}" ]]; then
    echo "TOXINPRED: Input file outermembrane_sequences is empty."
    exit 100
fi 

    # Run ToxinPred3
    toxinpred3 -i ${outermembrane_sequences} -o outfile.csv --threshold ${params.threshold} --model ${params.model} --display ${params.toxinpredDisplay}

    # Collect sequence IDs predicted as Non-Toxin
    awk -F ',' 'NR > 1 && \$6 == "Non-Toxin" {print \$1}' outfile.csv > seq_id.txt

    # Make filtered FASTA and ID list
    seqkit grep -f seq_id.txt ${outermembrane_sequences} > non_toxins.fasta
    awk '/^>/ {sub(/^>/, ""); print \$1}' non_toxins.fasta > TOXINPRED.ids

    # Ensure no CRLF issues
    tr -d '\\r' < ${deeplocpro_csv} > dl.tmp && mv dl.tmp ${deeplocpro_csv}

    # Extend the CSV: 1 = non-toxic, 0 = toxic
    awk 'BEGIN{FS=OFS=","}
         NR==FNR { ids[\$1]=1; next }
         FNR==1  { print \$0 ",TOXINPRED"; next }
         { id=\$1; print \$0 "," (id in ids ? 1 : 0) }
    ' TOXINPRED.ids ${deeplocpro_csv} > toxinpred.csv
    """
}
