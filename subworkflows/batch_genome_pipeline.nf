include { PROKKA }         from '../modules/PROKKA.nf'
include { ROARY }         from '../modules/ROARY.nf'
include { ROARY_2 }         from '../modules/ROARY2.nf'
include { ALGPRED }        from '../modules/ALGPRED.nf'
include { VFDB }           from '../modules/VFDB.nf'
include { DEEPLOCPRO }     from '../modules/DEEPLOCPRO.nf'
include { DEEPTHMMM }      from '../modules/DEEPTHMMM.nf'
include { DEEPTHMMM_2 }    from '../modules/DEEPTHMMM2.nf'
include { SIGNALP }        from '../modules/SIGNALP.nf'
include { HUMAN_HOMOLOGS } from '../modules/HUMAN_HOMOLOGS.nf'
include { TOXINPRED }   from '../modules/TOXINPRED.nf'
include { MHCNUGGETS_I }   from '../modules/MHCNUGGETS_I.nf'
include { MHCNUGGETS_II }   from '../modules/MHCNUGGETS_II.nf'

workflow PIPELINE_BATCH_GENOME {
    take:
        genome_sequences

    main:
        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)
 
        VFDB_ch = VFDB(ROARY2_ch.protein_sequences, file('Databases/VFDB/VFDB_db.dmnd'))
        
        HUMAN_HOMOLOGS_ch = HUMAN_HOMOLOGS(VFDB_ch, file('Databases/Human/human_db.dmnd'))     
      
        ALGPRED_ch = ALGPRED(HUMAN_HOMOLOGS_ch)
         
        SIGNALP_ch  = SIGNALP(ALGPRED_ch)
           
        DEEPLOCPRO_ch = DEEPLOCPRO(SIGNALP_ch)

        TOXINPRED_ch = TOXINPRED(DEEPLOCPRO_ch)   

        DEEPTHMMM_ch = DEEPTHMMM(TOXINPRED_ch)

        DEEPTHMMM2_ch = DEEPTHMMM_2(
        DEEPTHMMM_ch.gff3,
        DEEPTHMMM_ch.non_toxins)

        MHCNUGGETS_I(DEEPTHMMM2_ch, file("MHC_I.py"))
        MHCNUGGETS_II(DEEPTHMMM2_ch, file("MHC_II.py"))

    emit:
        final_output = MHCNUGGETS_I.out
}


