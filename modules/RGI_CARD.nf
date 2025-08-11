process RGI_CARD {
    container 'quay.io/biocontainers/rgi:6.0.3--pyha8f3691_0'

    publishDir "Results/CARD_output", mode:"copy"

    input:
    path non_allergen_sequences

    output:
    path "rgi_proteins.faa", emit:RGI_proteins

    script:
    """
    rgi main \
      --input_sequence ${non_allergen_sequences} \
      --output_file results \
      --input_type protein \
      --clean

    awk -F '\t' 'NR > 1 {print ">" \$1 "\\n" \$19}' results.txt | \
    awk '/^>/ {print; next} {sub(/\\*\$/, ""); print}' > rgi_proteins.faa
    """
}
