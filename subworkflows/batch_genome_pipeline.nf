include { PROKKA }         from '../modules/PROKKA.nf'
include { ROARY }          from '../modules/ROARY.nf'
include { ROARY_2 }        from '../modules/ROARY2.nf'
include { ALGPRED }        from '../modules/ALGPRED.nf'
include { VFDB }           from '../modules/VFDB.nf'
include { DEEPLOCPRO }     from '../modules/DEEPLOCPRO.nf'
include { DEEPTHMMM }      from '../modules/DEEPTHMMM.nf'
include { DEEPTHMMM_2 }    from '../modules/DEEPTHMMM2.nf'
include { SIGNALP }        from '../modules/SIGNALP.nf'
include { HUMAN_HOMOLOGS } from '../modules/HUMAN_HOMOLOGS.nf'
include { TOXINPRED }      from '../modules/TOXINPRED.nf'
include { MHCNUGGETS_I }   from '../modules/MHCNUGGETS_I.nf'
include { MHCNUGGETS_II }  from '../modules/MHCNUGGETS_II.nf'
include { PROTEOME_IDS }   from '../modules/PROTEOME_IDS.nf'
include { PROTPARAM }      from '../modules/PROTPARAM.nf'
include { CD_HIT }         from '../modules/CD_HIT.nf'


workflow PIPELINE_BATCH_GENOME {
    take:
        genome_sequences

    main:
        if (params.mode == 'fullmatrix') {
        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)

        CD_HIT_ch=CD_HIT(ROARY2_ch.protein_sequences)

        start_ch = Channel.value(true)

        PROTEOME_IDS_ch = PROTEOME_IDS(CD_HIT_ch.clustered_proteins,start_ch)
        VFDB_ch          = VFDB(CD_HIT_ch.clustered_proteins, file('Databases/VFDB/VFDB_db.dmnd'), PROTEOME_IDS_ch.proteome_csv,PROTEOME_IDS_ch.ready)
        HUMAN_HOMOLOGS_ch= HUMAN_HOMOLOGS(CD_HIT_ch.clustered_proteins, file('Databases/Human/human_db.dmnd'), VFDB_ch.vfdb_csv,VFDB_ch.ready)
        ALGPRED_ch       = ALGPRED(CD_HIT_ch.clustered_proteins, HUMAN_HOMOLOGS_ch.human_homologs_csv,HUMAN_HOMOLOGS_ch.ready)
        SIGNALP_ch       = SIGNALP(CD_HIT_ch.clustered_proteins, ALGPRED_ch.algpred_csv,ALGPRED_ch.ready)
        DEEPLOCPRO_ch    = DEEPLOCPRO(CD_HIT_ch.clustered_proteins, SIGNALP_ch.signalp_csv,SIGNALP_ch.ready)
        TOXINPRED_ch     = TOXINPRED(CD_HIT_ch.clustered_proteins, DEEPLOCPRO_ch.deeplocpro_csv,DEEPLOCPRO_ch.ready)
        DEEPTHMMM_ch     = DEEPTHMMM(CD_HIT_ch.clustered_proteins,TOXINPRED_ch.ready)
        DEEPTHMMM2_ch    = DEEPTHMMM_2(DEEPTHMMM_ch.gff3, DEEPTHMMM_ch.non_toxins, TOXINPRED_ch.toxinpred_csv,DEEPTHMMM_ch.ready)
        PROTPARAM_ch     = PROTPARAM(CD_HIT_ch.clustered_proteins, file("scripts/PROTPARAM.py"),DEEPTHMMM2_ch.ready)

        }
        else {
        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)

        CD_HIT_ch=CD_HIT(ROARY2_ch.protein_sequences)
         
        start_ch = Channel.value(true)
        PROTEOME_IDS_ch = PROTEOME_IDS(CD_HIT_ch.clustered_proteins,start_ch)
        
        VFDB_ch = VFDB(CD_HIT_ch.clustered_proteins,file('Databases/VFDB/VFDB_db.dmnd'),PROTEOME_IDS_ch.proteome_csv,PROTEOME_IDS_ch.ready)
        HUMAN_HOMOLOGS_ch = HUMAN_HOMOLOGS(VFDB_ch.virulent_proteins, file('Databases/Human/human_db.dmnd'),VFDB_ch.vfdb_csv,VFDB_ch.ready)
        ALGPRED_ch = ALGPRED(HUMAN_HOMOLOGS_ch.Non_human_proteins, HUMAN_HOMOLOGS_ch.human_homologs_csv,HUMAN_HOMOLOGS_ch.ready)
        SIGNALP_ch  = SIGNALP(ALGPRED_ch.non_allergen_sequences,ALGPRED_ch.algpred_csv,ALGPRED_ch.ready)
        DEEPLOCPRO_ch = DEEPLOCPRO(SIGNALP_ch.signalp_sequences,SIGNALP_ch.signalp_csv,SIGNALP_ch.ready)
        TOXINPRED_ch = TOXINPRED(DEEPLOCPRO_ch.outermembrane_sequences,DEEPLOCPRO_ch.deeplocpro_csv,DEEPLOCPRO_ch.ready)
        DEEPTHMMM_ch = DEEPTHMMM(TOXINPRED_ch.non_toxins,TOXINPRED_ch.ready)
        DEEPTHMMM2_ch = DEEPTHMMM_2(DEEPTHMMM_ch.gff3, DEEPTHMMM_ch.non_toxins,TOXINPRED_ch.toxinpred_csv,DEEPTHMMM_ch.ready)

        PROTPARAM_ch = PROTPARAM(DEEPTHMMM2_ch.TMR_sequence, file("scripts/PROTPARAM.py"),DEEPTHMMM2_ch.ready)

        MHCNUGGETS_I(DEEPTHMMM2_ch.TMR_sequence, file("scripts/MHC_I.py"),PROTPARAM_ch.ready)
        MHCNUGGETS_II(DEEPTHMMM2_ch.TMR_sequence, file("scripts/MHC_II.py"),PROTPARAM_ch.ready)
        }
}


