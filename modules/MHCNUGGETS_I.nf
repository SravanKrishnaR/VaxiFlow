process MHCNUGGETS_I {
   container 'mhcnuggets:latest'

   publishDir "Results/MHCNUGGETS_I", mode: "copy"

   input:
   path TMR_sequence
   path MHC_I

   output:
   path "filtered_predictions_classI.csv"

   stub:
   """
   echo 'peptide,score' > filtered_predictions.csv
   echo 'MVKELTNVL,0.92' >> filtered_predictions.csv
   """

   script:
   """
   python ${MHC_I} -p ${TMR_sequence}
   """
}
