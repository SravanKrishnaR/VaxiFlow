process SIGNALP {
    container 'sravankrishna47/signalp-fast'

    publishDir "Results/SIGNALP", mode: "copy"

    input:
    path non_allergen_sequences
    path algpred_csv
    val ready
 
    output:
    path "signalp/processed_entries.fasta", emit: signalp_sequences
    path "SIGNALP.ids", emit: SIGNALP_ids
    path "signalp.csv", emit: signalp_csv
    val true, emit: ready

    stub:
    """
    mkdir -p signalp
    echo '>stub_signalp\nMVKELRESTK' > signalp/processed_entries.fasta
    cp ${algpred_csv} signalp.csv
    """

    script:
    """
    mkdir -p signalp

    # Run SignalP
    signalp6 --fastafile ${non_allergen_sequences} \
             --organism ${params.organism} \
             --output_dir signalp \
             --format txt --mode fast

    # Extract pure IDs (remove ">" and keep only first token)
    awk '/^>/ {sub(/^>/,""); print \$1}' signalp/processed_entries.fasta > SIGNALP.ids

    # Ensure CSV line endings are clean
    tr -d '\\r' < ${algpred_csv} > algpred.tmp && mv algpred.tmp ${algpred_csv}

    # Add SIGNALP column
    awk 'BEGIN{FS=OFS=","}
         NR==FNR { ids[\$1]=1; next }
         FNR==1  { print \$0 ",SIGNALP"; next }
         { id=\$1; print \$0 "," (id in ids ? 1 : 0) }
    ' SIGNALP.ids ${algpred_csv} > signalp.csv
    """
}
