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

//*************************************************
def header() {

    c_reset  = params.monochrome_logs ? '' : "\033[0m"
    c_blue   = params.monochrome_logs ? '' : "\033[0;34m"
    c_purple = params.monochrome_logs ? '' : "\033[0;35m"
    c_dim    = params.monochrome_logs ? '' : "\033[2m"

    return """
    -${c_dim}--------------------------------------------------${c_reset}-
    ${c_blue} VaxiFlow${c_reset} — Reverse Vaccinology Pipeline
    ${c_purple} Version: ${workflow.manifest.version}${c_reset}
    -${c_dim}--------------------------------------------------${c_reset}-
    """.stripIndent()
}


//*************************************************
def helpMSG() {

    log.info """
VaxiFlow — Automated Reverse Vaccinology using Nextflow

DESCRIPTION
    VaxiFlow is a modular and reproducible Nextflow pipeline for
    high-throughput vaccine candidate discovery using immunoinformatics tools.
    It supports genome and proteome-based analyses and applies
    standardized filtering to prioritize antigenic candidates.

USAGE
    nextflow run SravanKrishnaR/VaxiFlow [MODE] [OPTIONS]

INPUT MODES (choose one)
    --genomes <"data/*.fna">     Batch genome analysis (multi-strain)
    --genome  <genome.fna>       Single genome analysis
    --proteome <proteins.faa>    Proteome-only analysis

COMMON OPTIONS
    --outdir <dir>               Output directory (default: Results)
    --cpus <int>                 CPUs per process (default: 12)
    --memory <str>               Memory per process (default: 8 GB)
    --publish_mode <copy|link>   Output publish mode
    --filtered                   Apply all filtering steps (default)
    --unfiltered                 Run tools without filtering
    --monochrome_logs            Disable colored logs

PIPELINE STEPS
    • Genome annotation (PROKKA)
    • Pangenome analysis (ROARY) [batch mode]
    • Virulence filtering (VFDB)
    • Host homology screening (Human BLAST)
    • Signal peptide detection (SignalP)
    • Subcellular localization (DeepLocPro)
    • Transmembrane filtering (DeepTMHMM)
    • Toxicity prediction (ToxinPred)
    • Allergenicity prediction (AlgPred)
    • Epitope prediction (IEDB I & II)

EXECUTION PROFILES
    -profile docker              Run using Docker (recommended)
    -profile test_genome         Test run (single genome)
    -profile test_genomes        Test run (batch genomes)
    -profile test_proteome       Test run (proteome)

EXAMPLE
    nextflow run SravanKrishnaR/VaxiFlow \\
        --genomes "data/*.fna" \\
        --outdir Results \\
        -profile docker

OTHER
    --help                       Show this help message and exit
"""
}
