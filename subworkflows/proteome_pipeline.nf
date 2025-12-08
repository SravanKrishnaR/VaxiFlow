include { ALGPRED }        from '../modules/ALGPRED.nf'
include { VFDB }           from '../modules/VFDB.nf'
include { DEEPLOCPRO }     from '../modules/DEEPLOCPRO.nf'
include { DEEPTHMMM }      from '../modules/DEEPTHMMM.nf'
include { DEEPTHMMM_2 }    from '../modules/DEEPTHMMM2.nf'
include { SIGNALP }        from '../modules/SIGNALP.nf'
include { HUMAN_HOMOLOGS } from '../modules/HUMAN_HOMOLOGS.nf'
include { TOXINPRED }      from '../modules/TOXINPRED.nf'
include { PROTPARAM }      from '../modules/PROTPARAM.nf'
include { MHC_I }          from '../modules/MHC_I.nf'
include { MHC_II }         from '../modules/MHC_II.nf'
include { PROTEOME_IDS }   from '../modules/PROTEOME_IDS.nf'

workflow PIPELINE_PROTEOME {
    take:
        protein_sequences

    main:
        if (params.mode == 'unfiltered') {
        PROTEOME_IDS_ch = PROTEOME_IDS(protein_sequences)
        VFDB_ch          = VFDB(protein_sequences, PROTEOME_IDS_ch.proteome_csv)
        HUMAN_HOMOLOGS_ch= HUMAN_HOMOLOGS(protein_sequences, VFDB_ch.vfdb_csv)
        ALGPRED_ch       = ALGPRED(protein_sequences, HUMAN_HOMOLOGS_ch.human_homologs_csv)
        SIGNALP_ch       = SIGNALP(protein_sequences, ALGPRED_ch.algpred_csv)
        DEEPLOCPRO_ch    = DEEPLOCPRO(protein_sequences, SIGNALP_ch.signalp_csv)
        TOXINPRED_ch     = TOXINPRED(protein_sequences, DEEPLOCPRO_ch.deeplocpro_csv)
	DEEPTHMMM_ch     = DEEPTHMMM(protein_sequences, TOXINPRED_ch.toxinpred_csv)
        DEEPTHMMM2_ch    = DEEPTHMMM_2(DEEPTHMMM_ch.gff3, DEEPTHMMM_ch.non_toxins, DEEPTHMMM_ch.toxinpred_csv)
        
        PROTPARAM_ch = PROTPARAM(protein_sequences, file("bin/PROTPARAM.py"))

        MHC_I(protein_sequences, file("bin/MHC_I.py"))
        MHC_II(protein_sequences, file("bin/MHC_II.py"))

        } 
        else if (params.mode == 'filtered') {
        PROTEOME_IDS_ch = PROTEOME_IDS(protein_sequences)
        VFDB_ch = VFDB(protein_sequences, PROTEOME_IDS_ch.proteome_csv)
        HUMAN_HOMOLOGS_ch = HUMAN_HOMOLOGS(VFDB_ch.virulent_proteins, VFDB_ch.vfdb_csv)
        ALGPRED_ch = ALGPRED(HUMAN_HOMOLOGS_ch.Non_human_proteins, HUMAN_HOMOLOGS_ch.human_homologs_csv)
        SIGNALP_ch  = SIGNALP(ALGPRED_ch.non_allergen_sequences,ALGPRED_ch.algpred_csv)
        DEEPLOCPRO_ch = DEEPLOCPRO(SIGNALP_ch.signalp_sequences,SIGNALP_ch.signalp_csv)
        TOXINPRED_ch = TOXINPRED(DEEPLOCPRO_ch.outermembrane_sequences,DEEPLOCPRO_ch.deeplocpro_csv)
        DEEPTHMMM_ch = DEEPTHMMM(TOXINPRED_ch.non_toxins,TOXINPRED_ch.toxinpred_csv)
        DEEPTHMMM2_ch = DEEPTHMMM_2(DEEPTHMMM_ch.gff3, DEEPTHMMM_ch.non_toxins,DEEPTHMMM_ch.toxinpred_csv)

        PROTPARAM_ch = PROTPARAM(DEEPTHMMM2_ch.TMR_sequence, file("bin/PROTPARAM.py"))

        MHC_I(DEEPTHMMM2_ch.TMR_sequence, file("bin/MHC_I.py"))
        MHC_II(DEEPTHMMM2_ch.TMR_sequence, file("bin/MHC_II.py"))
        }
}
