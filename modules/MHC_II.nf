process MHC_II {
   container 'sravankrishna47/iedb_mhc_ii'
   
   errorStrategy {
	task.exitStatus == 100 ? 'ignore' : 'terminate'
   }

   publishDir "${params.outdir}/MHC_II/${name}", mode: "copy"

   input:
   tuple val(name), path(PHOBIUS_fasta), path(phobius_csv)

   output:
   tuple val(name), path(PHOBIUS_fasta), path(phobius_csv), path("*.txt"), emit: MHC_II_out

   stub:
   """
   echo 'peptide,score' > filtered_predictions.csv
   echo 'MVKELTNVL,0.92' >> filtered_predictions.csv
   """

   script:
   """
   if [[ '${params.mode}' == 'filtered' && ! -s "${PHOBIUS_fasta}" ]]; then
    echo "MHC_II: Input file PHOBIUS_fasta is empty."
    exit 100
fi

   python3 /app/MHC_II.py --fasta ${PHOBIUS_fasta} --method ${params.MHC_II_method} --length ${params.MHC_II_length} --alleles ${params.MHC_II_alleles}
   """
}
