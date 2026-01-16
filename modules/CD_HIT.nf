process CD_HIT {
    label 'light'

    publishDir "${params.outdir}/CD_HIT", mode: 'copy'

    container 'sravankrishna47/cd-hit:latest'

    input:
    tuple val(name), path(protein_sequences)

    output:
    tuple val(name), path("clustered.faa"), emit: clustered_proteins
    tuple val(name), path("clustered.faa.clstr"), emit: cluster_report

    script:
    """
    cd-hit -i ${protein_sequences} -o clustered.faa -c ${params.SequenceIdentity} -n ${params.WordLength} -d ${params.DescpLength}
    """
}
