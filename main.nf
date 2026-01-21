include { PIPELINE_PROTEOME }       from './subworkflows/proteome_pipeline.nf'
include { PIPELINE_PANGENOME }      from './subworkflows/pangenome_pipeline.nf'
include { PIPELINE_GENOME }         from './subworkflows/genome_pipeline.nf'
include { paramsHelp }              from 'plugin/nf-schema'

params.pangenome  = null
params.genome  = null
params.proteome = null


workflow {
if (params.proteome) {
        protein_sequences_ch = Channel.fromPath(params.proteome).map{ file -> tuple(file.baseName,file) }
        PIPELINE_PROTEOME(protein_sequences_ch)
}

if (params.pangenome) {
        genome_sequences = Channel.fromPath(params.pangenome)
        PIPELINE_PANGENOME(genome_sequences)
}

if (params.genome) {
        genome_sequence = Channel.fromPath(params.genome)
        PIPELINE_GENOME(genome_sequence)
    }
}

if (params.help) {
        log.info paramsHelp(
            command: "nextflow run SravanKrishnaR/VaxiFlow",
            beforeText: "VaxiFlow — Reverse Vaccinology Pipeline",
            afterText: "Documentation: https://github.com/SravanKrishnaR/VaxiFlow"
        )
        exit 0
}
