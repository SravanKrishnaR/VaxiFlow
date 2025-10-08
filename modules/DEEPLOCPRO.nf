process DEEPLOCPRO {
    container 'sravankrishna47/deeplocpro'

    publishDir "Results/DEEPLOCPRO", mode: "copy"

    input:
    path signalp_sequences
    path signalp_csv
    val ready

    output:
    path "outer_membrane.fasta", emit: outermembrane_sequences
    path "DEEPLOCPRO.ids", emit: DEEPLOCPRO_ids
    path "deeplocpro.csv", emit: deeplocpro_csv
    val true, emit: ready

    stub:
    """
    echo '>stub_om\nGAVLLLLAVVV' > outer_membrane.fasta
    cp ${signalp_csv} deeplocpro.csv
    """

    script:
    """
    export TORCH_HOME=\$PWD/.cache

    # Clean input (DeepLocPro sometimes crashes on "*")
    sed 's/\\*//g' ${signalp_sequences} > cleaned_input.fasta

    # Run DeepLocPro
    deeplocpro -f cleaned_input.fasta -o deeploc_output -g ${params.group}

    # Extract subcellular location info
    mv deeploc_output/results_*.csv deeploc_results.csv

    # Collect IDs that are Outer Membrane or Extracellular
    awk -F',' '\$3 == "Outer Membrane" || \$3 == "Extracellular" {print \$2}' deeploc_results.csv > ids.txt

    # Build filtered FASTA + ID list
    seqkit grep -f ids.txt ${signalp_sequences} > outer_membrane.fasta
    awk '/^>/ {sub(/^>/,""); print \$1}' outer_membrane.fasta > DEEPLOCPRO.ids

    # Clean CSV
    tr -d '\\r' < ${signalp_csv} > signalp.tmp && mv signalp.tmp ${signalp_csv}

    # Add DEEPLOCPRO column
    awk 'BEGIN{FS=OFS=","}
         NR==FNR { ids[\$1]=1; next }
         FNR==1  { print \$0 ",DEEPLOCPRO"; next }
         { id=\$1; print \$0 "," (id in ids ? 1 : 0) }
    ' DEEPLOCPRO.ids ${signalp_csv} > deeplocpro.csv
    """
}
