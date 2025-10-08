include { PIPELINE_PROTEOME }       from './subworkflows/proteome_pipeline.nf'
include { PIPELINE_BATCH_GENOME }   from './subworkflows/batch_genome_pipeline.nf'
include { PIPELINE_GENOME }         from './subworkflows/genome_pipeline.nf'

params.genomes  = null
params.genome  = null
params.proteome = null


workflow {
if (params.proteome) {
        protein_sequences = Channel.fromPath(params.proteome)
        PIPELINE_PROTEOME(protein_sequences)
}

if (params.genomes) {
        genome_sequences = Channel.fromPath(params.genomes)
        PIPELINE_BATCH_GENOME(genome_sequences)
}

if (params.genome) {
        genome_sequence = Channel.fromPath(params.genome)
        PIPELINE_GENOME(genome_sequence)
    }
}
