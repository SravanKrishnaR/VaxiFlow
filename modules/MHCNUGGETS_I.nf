process MHCNUGGETS_I {
   container 'sravankrishna47/mhcnuggets'

   publishDir "Results/MHCNUGGETS_I", mode: "copy"

   input:
   path TMR_sequence
   path MHC_I
   val ready

   output:
   path "*.csv"
   val true, emit: ready

   stub:
   """
   echo 'peptide,score' > filtered_predictions.csv
   echo 'MVKELTNVL,0.92' >> filtered_predictions.csv
   """

   script:
   """
   python ${MHC_I} -i ${TMR_sequence}
   """
}
