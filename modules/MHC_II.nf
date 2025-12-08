process MHC_II {
   container 'iedb:latest'

   publishDir "Results/MHCNUGGETS_II", mode: "copy"

   input:
   path TMR_sequence
   path MHC_II
   path deepthmmm_csv

   output:
   path "filtered_predictions_classII.csv"

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
