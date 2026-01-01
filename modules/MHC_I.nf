process MHC_I {
   conda "${projectDir}/bin/envs/mhc_iedb.yml"

   errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

   publishDir "${params.outdir}/MHC_I", mode: "copy"

   input:
   path TMR_sequence
   path MHC_I
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
    echo "MHC_I: Input file TMR_sequence is empty."
    exit 100
fi

   python ${MHC_I} --input ${TMR_sequence}
   """
}
