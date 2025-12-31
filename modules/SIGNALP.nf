process SIGNALP {
    container 'sravankrishna47/signalp-fast:latest'

    errorStrategy {
        params.mode == 'filtered' ? 'terminate' : 'ignore'
    }

    publishDir "Results/SIGNALP", mode: "copy"

    input:
    path non_allergen_sequences
    path algpred_csv
 
    output:
    path "signalp/processed_entries.fasta", emit: signalp_sequences
    path "SIGNALP.ids", emit: SIGNALP_ids
    path "signalp.csv", emit: signalp_csv
    path "signalp"

    stub:
    """
    mkdir -p signalp
    echo '>stub_signalp\nMVKELRESTK' > signalp/processed_entries.fasta
    cp ${algpred_csv} signalp.csv
    """

    script:
    """
    if [[ '${params.mode}' == 'filtered' && ! -s "${non_allergen_sequences}" ]]; then
    echo "SIGNALP: Input file non_allergen_sequences is empty."
    exit 100
fi

    mkdir -p signalp

    # Run SignalP
    signalp6 --fastafile ${non_allergen_sequences} --organism ${params.organism} --output_dir signalp --mode ${params.signalpMode}


    # Extract pure IDs (remove ">" and keep only first token)
    awk '/^>/ {sub(/^>/,""); print \$1}' signalp/processed_entries.fasta > SIGNALP.ids

    # Ensure CSV line endings are clean
    tr -d '\\r' < ${algpred_csv} > algpred.tmp && mv algpred.tmp ${algpred_csv}

    # Add SIGNALP column
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
}' SIGNALP.ids ${algpred_csv} > signalp.csv

    """
}
