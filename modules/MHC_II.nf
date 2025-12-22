process MHC_II {
   conda "bin/envs/mhc_iedb.yml"
   
   errorStrategy {
	task.exitStatus == 100 ? 'ignore' : 'terminate'
   }

   publishDir "Results/MHC_II", mode: "copy"

   input:
   path TMR_sequence
   path MHC_II
   path deepthmmm_csv

   output:
   path "*.csv"

   stub:
   """
   echo 'peptide,score' > filtered_predictions.csv
   echo 'MVKELTNVL,0.92' >> filtered_predictions.csv
   """

   script:
   """
   if [[ '${params.mode}' == 'filtered' && ! -s "${TMR_sequence}" ]]; then
    echo "MHC_II: Input file TMR_sequence is empty."
    exit 100
fi

   python ${MHC_II} --input ${TMR_sequence}
   """
}
