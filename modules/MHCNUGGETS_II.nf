process MHCNUGGETS_II {
   container 'sravankrishna47/mhcnuggets'

   publishDir "Results/MHCNUGGETS_II", mode: "copy"

   input:
   path TMR_sequence
   path MHC_II
   val ready

   output:
   path "filtered_predictions_classII.csv"
   val true, emit: ready

   stub:
   """
   echo 'peptide,score' > filtered_predictions.csv
   echo 'MVKELTNVL,0.92' >> filtered_predictions.csv
   """

   script:
   """
   python ${MHC_II} --input ${TMR_sequence}
   """
}
