# VaxiFlow
VaxiFlow, An automated Nextflow based pipeline for reverse vaccinology that streamlines vaccine candidate discovery through comprehensive antigen prediction, filtering, and prioritization workflows.

Requirements:
`Nextflow` 
`Docker` 
`DIAMOND BLAST` 
`seqkit` 

FOR PROTEOME ANALYSIS
```bash
nextflow run main.nf --proteome "DATA/protein.faa" 
```

FOR MULTI-GENOME ANALYSIS
```bash
nextflow run main.nf --genomes "DATA/*.fna" 
```

FOR SINGLE GENOME ANALYSIS
```bash
nextflow run main.nf --genome "DATA/GCA_000240185.2_ASM24018v2_genomic.fna" 
```
