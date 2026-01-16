process B_CELL {
    container 'iedb_bcell:latest'

    errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

    publishDir "${params.outdir}/B_CELL/${name}", mode:'copy'

    input:
    tuple val(name), path(PHOBIUS_fasta), path(phobius_csv)

    output:
    tuple val(name), path(PHOBIUS_fasta), path(phobius_csv), path("*_B_CELL_results.txt"), emit: B_CELL_out

    script:
    """
    seqkit seq ${PHOBIUS_fasta} -i > cleaned_PHOBIUS.fasta
    python /app/predict_antibody_epitope.py -m Chou-Fasman -f cleaned_PHOBIUS.fasta > ${name}_B_CELL_results.txt
    """

}
