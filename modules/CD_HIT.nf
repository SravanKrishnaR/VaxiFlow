process CD_HIT {
    label 'light'

    publishDir "Results/CD_HIT", mode: 'copy'

    container 'biocontainers/cd-hit:v4.6.8-2-deb_cv1'

    input:
    path protein_sequences

    output:
    path "clustered.faa", emit: clustered_proteins
    path "clustered.faa.clstr"

    script:
    """
    cd-hit -i ${protein_sequences} \ 
	   -o clustered.faa \
	   -c ${params.SequenceIdentity} \
	   -n ${params.WordLength} \
	   -d ${parmas.DescpLength}
    """
}
