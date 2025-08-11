process MHCNUGGETS_II {
   container 'mhcnuggets:latest'

   publishDir "Results/MHCNUGGETS_II", mode: "copy"

   input:
   path TMR_sequence
   path MHC_II

   output:
   path "filtered_predictions_classII.csv"

   stub:
   """
   echo 'peptide,score' > filtered_predictions.csv
   echo 'MVKELTNVL,0.92' >> filtered_predictions.csv
   """

   script:
   """
   python ${MHC_II} -p ${TMR_sequence}
   """
}
