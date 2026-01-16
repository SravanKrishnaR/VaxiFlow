process PROTEOME_IDS {
    publishDir "${params.outdir}/PROTEOME_IDS/${name}", mode: 'copy'

    input:
    tuple val(name), path(clustered_proteins)

    output:
    tuple val(name), path("proteome.csv"), emit: proteome_csv

    script:
    """
    awk '/^>/ {sub(/^>/, ""); print \$1}' ${clustered_proteins} | awk 'BEGIN{OFS=","; print "PROTEOME_IDS"} {print \$1}' > proteome.csv
    """
}
