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
include { MHC_I }          from '../modules/MHC_I.nf'
include { MHC_II }         from '../modules/MHC_II.nf'
include { PROTEOME_IDS }   from '../modules/PROTEOME_IDS.nf'
include { PROTPARAM }      from '../modules/PROTPARAM.nf'
include { CD_HIT }         from '../modules/CD_HIT.nf'


workflow PIPELINE_BATCH_GENOME {
    take:
        genome_sequences

    main:
        if (params.mode == 'unfiltered') {
        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)

        CD_HIT_ch=CD_HIT(ROARY2_ch.protein_sequences)

        PROTEOME_IDS_ch = PROTEOME_IDS(CD_HIT_ch.clustered_proteins)
        VFDB_ch          = VFDB(CD_HIT_ch.clustered_proteins, PROTEOME_IDS_ch.proteome_csv)
        HUMAN_HOMOLOGS_ch= HUMAN_HOMOLOGS(CD_HIT_ch.clustered_proteins, VFDB_ch.vfdb_csv)
        ALGPRED_ch       = ALGPRED(CD_HIT_ch.clustered_proteins, HUMAN_HOMOLOGS_ch.human_homologs_csv)
        SIGNALP_ch       = SIGNALP(CD_HIT_ch.clustered_proteins, ALGPRED_ch.algpred_csv)
        DEEPLOCPRO_ch    = DEEPLOCPRO(CD_HIT_ch.clustered_proteins, SIGNALP_ch.signalp_csv)
        TOXINPRED_ch     = TOXINPRED(CD_HIT_ch.clustered_proteins, DEEPLOCPRO_ch.deeplocpro_csv)
        DEEPTHMMM_ch     = DEEPTHMMM(CD_HIT_ch.clustered_proteins, TOXINPRED_ch.toxinpred_csv)
        DEEPTHMMM2_ch    = DEEPTHMMM_2(DEEPTHMMM_ch.gff3, DEEPTHMMM_ch.non_toxins, TOXINPRED_ch.toxinpred_csv)
        PROTPARAM_ch     = PROTPARAM(CD_HIT_ch.clustered_proteins, file("bin/PROTPARAM.py"), DEEPTHMMM2_ch.deepthmmm_csv)
  
        MHC_I(CD_HIT_ch.clustered_proteins, file("bin/MHC_I.py"), DEEPTHMMM2_ch.deepthmmm_csv)
        MHC_II(CD_HIT_ch.clustered_proteins, file("bin/MHC_II.py"), DEEPTHMMM2_ch.deepthmmm_csv)
        
        }
        else if (params.mode == 'filtered') {
        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)

        CD_HIT_ch=CD_HIT(ROARY2_ch.protein_sequences)
         
        PROTEOME_IDS_ch = PROTEOME_IDS(CD_HIT_ch.clustered_proteins)
        
        VFDB_ch = VFDB(CD_HIT_ch.clustered_proteins,PROTEOME_IDS_ch.proteome_csv)
        HUMAN_HOMOLOGS_ch = HUMAN_HOMOLOGS(VFDB_ch.virulent_proteins,VFDB_ch.vfdb_csv)
        ALGPRED_ch = ALGPRED(HUMAN_HOMOLOGS_ch.Non_human_proteins, HUMAN_HOMOLOGS_ch.human_homologs_csv)
        SIGNALP_ch  = SIGNALP(ALGPRED_ch.non_allergen_sequences,ALGPRED_ch.algpred_csv)
        DEEPLOCPRO_ch = DEEPLOCPRO(SIGNALP_ch.signalp_sequences,SIGNALP_ch.signalp_csv)
        TOXINPRED_ch = TOXINPRED(DEEPLOCPRO_ch.outermembrane_sequences,DEEPLOCPRO_ch.deeplocpro_csv)
        DEEPTHMMM_ch = DEEPTHMMM(TOXINPRED_ch.non_toxins, TOXINPRED_ch.toxinpred_csv)
        DEEPTHMMM2_ch = DEEPTHMMM_2(DEEPTHMMM_ch.gff3, DEEPTHMMM_ch.non_toxins,TOXINPRED_ch.toxinpred_csv)

        PROTPARAM_ch = PROTPARAM(DEEPTHMMM2_ch.TMR_sequence, file("scripts/PROTPARAM.py"), DEEPTHMMM2_ch.deepthmmm_csv)

        MHC_I(DEEPTHMMM2_ch.TMR_sequence, file("bin/MHC_I.py"), DEEPTHMMM2_ch.deepthmmm_csv)
        MHC_II(DEEPTHMMM2_ch.TMR_sequence, file("bin/MHC_II.py"), DEEPTHMMM2_ch.deepthmmm_csv)
        }
}


