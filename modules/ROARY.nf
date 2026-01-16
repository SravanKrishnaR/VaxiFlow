process ROARY {
    label 'heavy'
    tag "ROARY_pan_genome"

    container 'biocontainers/roary:v3.12.0dfsg-2-deb_cv1'
    publishDir "${params.outdir}/ROARY", mode: 'copy'

    input:
    path gff_ch 

    output:
    path "summary_statistics.txt", emit: summary_statistics 
    path "gene_presence_absence.csv", emit: gene_presence_absence
    path "pan_genome_reference.fa", emit: pan_genome_reference

    script:
    """
    roary -p ${params.cpus} -e -n -s -i ${params.identity} ${gff_ch.join(' ')}
    """

}
