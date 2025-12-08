process PROTEOME_IDS {
    publishDir "Results/PROTEOME_IDS", mode: 'copy'

    input:
    path clustered_proteins

    output:
    path "proteome.csv", emit: proteome_csv

    script:
    """
    awk '/^>/ {sub(/^>/, ""); print \$1}' ${clustered_proteins} | awk 'BEGIN{OFS=","; print "PROTEOME_IDS"} {print \$1}' > proteome.csv
    """
}
