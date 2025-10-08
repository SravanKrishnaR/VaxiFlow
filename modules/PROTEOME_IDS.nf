process PROTEOME_IDS {
    publishDir "Results/PROTEOME_IDS", mode: 'copy'

    input:
    path clustered_proteins
    val ready

    output:
    path "proteome.csv", emit: proteome_csv
    val true, emit: ready

    script:
    """
    awk '/^>/ {sub(/^>/, ""); print \$1}' ${clustered_proteins} | awk 'BEGIN{OFS=","; print "PROTEOME_IDS"} {print \$1}' > proteome.csv
    """
}
