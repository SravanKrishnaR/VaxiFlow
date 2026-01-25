process DEEPLOCPRO {
   container 'sravankrishna47/deeplocpro:latest'

    errorStrategy {
      task.exitStatus == 100 ? 'ignore' : 'terminate'
}

    publishDir "${params.outdir}/DEEPLOCPRO/${name}", mode: "copy"

    input:
    tuple val(name), path(signalp_sequences), path(signalp_csv)

    output:
    tuple val(name), path("outer_membrane.fasta"), emit: outermembrane_sequences
    tuple val(name), path("DEEPLOCPRO.ids"), emit: DEEPLOCPRO_ids
    tuple val(name), path("deeplocpro.csv"), emit: deeplocpro_csv
    tuple val(name), path("deeploc_results.csv")

    stub:
    """
    echo '>stub_om\nGAVLLLLAVVV' > outer_membrane.fasta
    cp ${signalp_csv} deeplocpro.csv
    """

    script:
    """
    export TORCH_HOME=\$PWD/.cache

    # If FASTA is empty and mode is filtered → kill pipeline
    # If FASTA is empty and mode is filtered → graceful stop
    if [[ '${params.mode}' == 'filtered' && ! -s "${signalp_sequences}" ]]; then
    echo "DEEPLOCPRO: No sequences to process in filtered mode — stopping gracefully."
    exit 100
fi


    # Clean input (DeepLocPro sometimes crashes on "*")
    sed 's/\\*//g' ${signalp_sequences} > cleaned_input.fasta

    # Run DeepLocPro
    deeplocpro -f cleaned_input.fasta -o deeploc_output -g ${params.group} -d ${params.device}

    # Extract subcellular location info
    mv deeploc_output/results_*.csv deeploc_results.csv

    # Collect IDs that are Outer Membrane or Extracellular
    awk -F',' '\$3 == "Outer Membrane" || \$3 == "Extracellular" || \$3 == "Cell wall & surface" {print \$2}' deeploc_results.csv > ids.txt

    # Build filtered FASTA + ID list
    seqkit grep -f ids.txt ${signalp_sequences} > outer_membrane.fasta
    awk '/^>/ {sub(/^>/,""); print \$1}' outer_membrane.fasta > DEEPLOCPRO.ids

    # Clean CSV
    tr -d '\\r' < ${signalp_csv} > signalp.tmp && mv signalp.tmp ${signalp_csv}

    # Add DEEPLOCPRO column
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
}' DEEPLOCPRO.ids ${signalp_csv} > deeplocpro.csv
    """
}
