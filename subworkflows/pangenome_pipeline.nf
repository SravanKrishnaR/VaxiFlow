include { PROKKA }         from '../modules/PROKKA.nf'
include { ROARY }          from '../modules/ROARY.nf'
include { ROARY_2 }        from '../modules/ROARY2.nf'
include { ALGPRED }        from '../modules/ALGPRED.nf'
include { VFDB }           from '../modules/VFDB.nf'
include { DEEPLOCPRO }     from '../modules/DEEPLOCPRO.nf'
include { SIGNALP }        from '../modules/SIGNALP.nf'
include { HUMAN_HOMOLOGS } from '../modules/HUMAN_HOMOLOGS.nf'
include { TOXINPRED }      from '../modules/TOXINPRED.nf'
include { PHOBIUS }        from '../modules/PHOBIUS.nf'
include { MHC_I }          from '../modules/MHC_I.nf'
include { MHC_II }         from '../modules/MHC_II.nf'
include { B_CELL }         from '../modules/B_CELL.nf'
include { PROTEOME_IDS }   from '../modules/PROTEOME_IDS.nf'
include { PROTPARAM }      from '../modules/PROTPARAM.nf'
include { CD_HIT }         from '../modules/CD_HIT.nf'


workflow PIPELINE_PANGENOME {
    take:
        genome_sequences

    main:
        if (params.mode == 'unfiltered') {

        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)
        
        if (params.end_at == 'PROKKA') {
            return
        }

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)

        if (params.end_at == 'ROARY') {
            return
        }

        CD_HIT_ch = CD_HIT(ROARY2_ch.protein_sequences)
        
        if (params.end_at == 'CD_HIT') {
            return
        }

        PROTEOME_IDS_ch = PROTEOME_IDS(CD_HIT_ch.clustered_proteins)
        
        if (params.end_at == 'PROTEOME_IDS') {
            return
        }

        VFDB_INPUT_ch = CD_HIT_ch.clustered_proteins.join(PROTEOME_IDS_ch.proteome_csv).map{ name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        VFDB_ch = VFDB(VFDB_INPUT_ch)
        
        if (params.end_at == 'VFDB') {
            return
        }

        HUMAN_HOMOLOGS_INPUT_ch = CD_HIT_ch.clustered_proteins.join(VFDB_ch.vfdb_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        HUMAN_HOMOLOGS_ch = HUMAN_HOMOLOGS(HUMAN_HOMOLOGS_INPUT_ch)

        if (params.end_at == 'HUMAN_HOMOLOGS') {
            return
        }

        ALGPRED_INPUT_ch = CD_HIT_ch.clustered_proteins.join(HUMAN_HOMOLOGS_ch.human_homologs_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        ALGPRED_ch = ALGPRED(ALGPRED_INPUT_ch)

        if (params.end_at == 'ALGPRED') {
            return
        }

        SIGNALP_INPUT_ch = CD_HIT_ch.clustered_proteins.join(ALGPRED_ch.algpred_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        SIGNALP_ch = SIGNALP(SIGNALP_INPUT_ch)

        if (params.end_at == 'SIGNALP') {
            return
        }

        DEEPLOCPRO_INPUT_ch  = CD_HIT_ch.clustered_proteins.join(SIGNALP_ch.signalp_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        DEEPLOCPRO_ch = DEEPLOCPRO(DEEPLOCPRO_INPUT_ch)

        if (params.end_at == 'DEEPLOCPRO') {
            return
        }

        TOXINPRED_INPUT_ch     = CD_HIT_ch.clustered_proteins.join(DEEPLOCPRO_ch.deeplocpro_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        TOXINPRED_ch = TOXINPRED(TOXINPRED_INPUT_ch)

        if (params.end_at == 'TOXINPRED') {
            return
        }

        PHOBIUS_INPUT_ch  = CD_HIT_ch.clustered_proteins.join(TOXINPRED_ch.toxinpred_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        PHOBIUS_ch = PHOBIUS(PHOBIUS_INPUT_ch)

        if (params.end_at == 'PHOBIUS') {
            return
        }

        PROTPARAM_INPUT_ch = CD_HIT_ch.clustered_proteins.join(PHOBIUS_ch.phobius_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        PROTPARAM_ch = PROTPARAM(PROTPARAM_INPUT_ch, file("${projectDir}/bin/PROTPARAM.py"))

        if (params.end_at == 'PROTPARAM') {
            return
        }

        B_CELL_INPUT_ch = CD_HIT_ch.clustered_proteins.join(PHOBIUS_ch.phobius_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        B_CELL_ch = B_CELL(B_CELL_INPUT_ch)

        if (params.end_at == 'MHC_II') {
            return
        }

        MHC_II_INPUT_ch = CD_HIT_ch.clustered_proteins.join(PHOBIUS_ch.phobius_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        MHC_II_ch = MHC_II(MHC_II_INPUT_ch)

        if (params.end_at == 'MHC_I') {
            return
        }

        MHC_I_INPUT_ch = CD_HIT_ch.clustered_proteins.join(PHOBIUS_ch.phobius_csv).map { name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        MHC_I_ch = MHC_I(MHC_I_INPUT_ch)

        }

        else if (params.mode == 'filtered') {

        genome_ch = genome_sequences.map { file -> tuple(file.baseName, file) }

        PROKKA_ch = PROKKA(genome_ch)
        
        if (params.end_at == 'PROKKA') {
            return
        }

        gff_files_ch = PROKKA_ch.gff_output.map { it[1] }.collect()

        ROARY_ch= ROARY(gff_files_ch)

        ROARY2_ch = ROARY_2(
        ROARY_ch.summary_statistics,
        ROARY_ch.gene_presence_absence,
        ROARY_ch.pan_genome_reference)
        
        if (params.end_at == 'ROARY2') {
            return
        }

        CD_HIT_ch = CD_HIT(ROARY2_ch.protein_sequences)

        if (params.end_at == 'CD_HIT') {
            return
        }

        PROTEOME_IDS_ch = PROTEOME_IDS(CD_HIT_ch.clustered_proteins)
        
        if (params.end_at == 'PROTEOME_IDS') {
            return
        }

        VFDB_INPUT_ch = CD_HIT_ch.clustered_proteins.join(PROTEOME_IDS_ch.proteome_csv).map{name, proteome, proteome_csv -> tuple(name, proteome, proteome_csv)}
        VFDB_ch = VFDB(VFDB_INPUT_ch)        

        if (params.end_at == 'VFDB') {
            return
        }

        HUMAN_HOMOLOGS_INPUT_ch = VFDB_ch.virulent_proteins.join(VFDB_ch.vfdb_csv).map{ name, virulent_proteins, vfdb_csv -> tuple(name, virulent_proteins, vfdb_csv) }
        HUMAN_HOMOLOGS_ch = HUMAN_HOMOLOGS(HUMAN_HOMOLOGS_INPUT_ch)
        
        if (params.end_at == 'HUMAN_HOMOLOGS') {
            return
        }

        ALGPRED_INPUT_ch = HUMAN_HOMOLOGS_ch.Non_human_proteins.join(HUMAN_HOMOLOGS_ch.human_homologs_csv).map { name, Non_human_proteins, human_homologs_csv -> tuple( name, Non_human_proteins, human_homologs_csv ) }
        ALGPRED_ch = ALGPRED(ALGPRED_INPUT_ch)
        
        if (params.end_at == 'ALGPRED') {
            return
        }

        SIGNALP_INPUT_ch = ALGPRED_ch.non_allergen_sequences.join(ALGPRED_ch.algpred_csv).map {name, non_allergen_sequences, algpred_csv -> tuple(name, non_allergen_sequences, algpred_csv)}
        SIGNALP_ch  = SIGNALP(SIGNALP_INPUT_ch)

        if (params.end_at == 'SIGNALP') {
            return
        }

        DEEPLOCPRO_INPUT_ch= SIGNALP_ch.signalp_sequences.join(SIGNALP_ch.signalp_csv).map { name, signalp_sequences, signalp_csv -> tuple(name, signalp_sequences, signalp_csv) }
        DEEPLOCPRO_ch = DEEPLOCPRO(DEEPLOCPRO_INPUT_ch)
        
        if (params.end_at == 'DEEPLOCPRO') {
            return
        }
        TOXINPRED_INPUT_ch = DEEPLOCPRO_ch.outermembrane_sequences.join(DEEPLOCPRO_ch.deeplocpro_csv).map { name, outermembrane_sequences, deeplocpro_csv -> tuple(name, outermembrane_sequences, deeplocpro_csv) }
        TOXINPRED_ch = TOXINPRED(TOXINPRED_INPUT_ch)
        
        if (params.end_at == 'TOXINPRED') {
            return
        }
        PHOBIUS_INPUT_ch = TOXINPRED_ch.non_toxins.join(TOXINPRED_ch.toxinpred_csv).map{ name, non_toxins, toxinpred_csv -> tuple(name, non_toxins, toxinpred_csv)}
        PHOBIUS_ch= PHOBIUS(PHOBIUS_INPUT_ch)

        if (params.end_at == 'PHOBIUS') {
            return
        }

        PROTPARAM_INPUT_ch = PHOBIUS_ch.PHOBIUS_fasta.join(PHOBIUS_ch.phobius_csv).map { name, PHOBIUS_fasta, phobius_csv -> tuple(name, PHOBIUS_fasta, phobius_csv)}
        PROTPARAM_ch = PROTPARAM(PROTPARAM_INPUT_ch, file("${projectDir}/bin/PROTPARAM.py"))

        if (params.end_at == 'PROTPARAM') {
            return
        }

        B_CELL_INPUT_ch = PROTPARAM_ch.PROTPARAM_out.map { name, PHOBIUS_fasta, phobius_csv, protparam_results -> tuple(name, PHOBIUS_fasta, phobius_csv)}
        B_CELL_ch = B_CELL(B_CELL_INPUT_ch)

        if (params.end_at == 'B_CELL') {
            return
        }

        MHC_II_INPUT_ch = B_CELL_ch.B_CELL_out.map { name, fasta, csv, bcell_res -> tuple(name, fasta, csv)}
        MHC_II_ch = MHC_II(MHC_II_INPUT_ch)

        if (params.end_at == 'MHC_II') {
            return
        }

        MHC_I_INPUT_ch = MHC_II_ch.MHC_II_out.map { name, fasta, csv, mhc2_res -> tuple(name, fasta, csv)}
        MHC_I(MHC_I_INPUT_ch)

        }
}





