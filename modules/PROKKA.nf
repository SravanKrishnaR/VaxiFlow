process PROKKA {
    label 'process_single'
    tag "${meta}"

    container 'staphb/prokka'
    publishDir "Results/PROKKA", mode: 'copy'

    input:
    tuple val(meta), path(genome)

    output:
    tuple val(meta), path("${meta}.gff"), emit: gff_output 
    path("${meta}.faa"), emit: protein_sequences

    script:
    """
    mkdir -p ${meta}
    prokka --force \
           --cpu ${params.cpus} \
           --kingdom ${params.kingdom} \
           --prefix ${meta} \
           --outdir ${meta} \
           ${genome}
    cp ${meta}/${meta}.gff .
    cp ${meta}/${meta}.faa .
    """

    stub:
    """
    mkdir -p ${meta}
    echo "##gff-version 3" > ${meta}.gff
    echo ">dummy_protein\nMADEUPSEQ" > ${meta}.faa
    """
}
