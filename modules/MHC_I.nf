process MHC_I {
   container 'sravankrishna47/iedb_mhc_i:latest'    
 
   errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

   publishDir "${params.outdir}/MHC_I/${name}", mode: "copy"

   input:
   tuple val(name), path(PHOBIUS_fasta), path(phobius_csv)

   output:
   tuple val(name), path(PHOBIUS_fasta), path(phobius_csv), path("*.txt"), emit: MHC_I_out

   script:
   """
   if [[ '${params.mode}' == 'filtered' && ! -s "${PHOBIUS_fasta}" ]]; then
    echo "MHC_I: Input file PHOBIUS_fasta is empty."
    exit 100
fi

   python3 /app/MHC_I.py --fasta ${PHOBIUS_fasta} --method ${params.MHC_I_method} --length ${params.MHC_I_length} --alleles ${params.MHC_I_alleles}
   """
}
