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

## Credits

This pipeline integrates several third-party tools and databases. We gratefully acknowledge the authors and maintainers of the following resources:

- **VFDB** (Virulence Factors Database)  
  VFDB 2022: a general classification scheme for bacterial virulence factors   
  Website: https://www.mgc.ac.cn/VFs/

- **HUMAN HOMOLOGS** (NCBI BLAST Human Protein Database)  
  National Center for Biotechnology Information.  
  Website: https://www.ncbi.nlm.nih.gov/

- **AlgPred 2.0**  
  AlgPred 2.0: an improved method for predicting allergenic proteins and mapping of IgE epitopes  
  Website: https://webs.iiitd.edu.in/raghava/algpred2/

- **SignalP 6.0**  
  SignalP 6.0 predicts all five types of signal peptides using protein language models  
  Website: https://services.healthtech.dtu.dk/services/SignalP-6.0/

- **DeepLocPro-1.0**  
  Predicting the subcellular location of prokaryotic proteins with DeepLocPro  
  Website: https://services.healthtech.dtu.dk/services/DeepLocPro-1.0/

- **ToxinPred 3.0**  
  ToxinPred 3.0: An improved method for predicting the toxicity of peptides
  Website: https://webs.iiitd.edu.in/raghava/toxinpred3/

- **DeepTMHMM-1.0**  
  DeepTMHMM predicts alpha and beta transmembrane proteins using deep neural networks
  Website: https://services.healthtech.dtu.dk/services/DeepTMHMM-1.0/

- **MHCnuggets I & II**  
  High-Throughput Prediction of MHC Class I and II Neoantigens with MHCnuggets  
  Website: https://github.com/KarchinLab/mhcnuggets
