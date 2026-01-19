# VaxiFlow
VaxiFlow, An automated Nextflow based pipeline for reverse vaccinology that streamlines vaccine candidate discovery through comprehensive antigen prediction, filtering, and prioritization workflows.

**Installation**
```bash
git clone https://github.com/SravanKrishnaR/VaxiFlow.git
```

**Requirements:**
`Nextflow >= 25.04.6.5954` 
`Docker` 

**FOR PROTEOME ANALYSIS**
```bash
nextflow run main.nf --proteome <input data> <parameters>
```

**FOR MULTI-GENOME ANALYSIS**
```bash
nextflow run main.nf --genomes <input data> <parameters>
```

**FOR SINGLE GENOME ANALYSIS**
```bash
nextflow run main.nf --genome <input data> <parameters>
```

**MODES:**
EACH OUTPUT GETS FILTERED
```bash
--filtered
```
RUN EACH TOOL INDIVIDUALLY
```bash
--unfiltered
```

<img width="2550" height="1986" alt="Image" src="https://github.com/user-attachments/assets/ba09b30e-29a4-4947-a35f-81f5e2f6b9fe" />

```
Pipeline Configuration Parameters
Parameter       Default Value  
--cpus            12                    
--memory          8 GB                           
--outdir          Results                        
--publish_mode    copy            
--pipeline_report pipeline_report 
--monochrome_logs false

-----------------------------------------------------------------------------------------------------------------------
| Tool           | Parameter            | Default value                              | Value used                     |
|----------------|----------------------|--------------------------------------------|--------------------------------|
| ROARY          | --identity           | 95                                         | 95                             |
|                |                      |                                            |                                |
| CD-HIT         | --SequenceIdentity   | 0.9                                        | 0.9                            |
|                | --WordLength         | 5                                          | 5                              |
|                | --DescpLength        | 0                                          | 0                              |
|                |                      |                                            |                                |
| PROKKA         | --kingdom            | Bacteria                                   | Archaea, Mitochondria, Viruses |
|                |                      |                                            |                                |
| TOXINPRED      | --threshold          | 0.38                                       | 0–1                            |
|                | --model              | 1                                          | 1, 2                           |
|                |                      |                                            |                                |
| DEEPLOCPRO     | --group              | negative                                   | archaea, positive              |
|                | --device             | cpu                                        | cuda, mps                      |
|                |                      |                                            |                                |
| ALGPRED        | --threshold          | 0.3                                        | 0–1                            |
|                |                      |                                            |                                |
| SIGNALP        | --organism           | other                                      | eukarya                        |
|                | --signalpMode        | fast                                       | slow, slow-sequential          |
|                |                      |                                            |                                |
| HUMAN_HOMOLOGS | --homologsdb         | '/app/human_db.dmnd'                       |                                |
|                |                      |                                            |                                |
| VFDB           | --vfdb               | '/app/VFDB_db.dmnd'                        |                                |
|                |                      |                                            |                                |
| MHC_I          | --MHC_I_method       | ann                                        |                                |
|                | --MHC_I_length       | 11                                         |                                |
|                | --MHC_I_alleles      | "/app/Resources/ann_human_allele.txt"      |                                |
|                |                      |                                            |                                |
|  MHC_II        | --MHC_II_method      | consensus3                                 |                                |
|                | --MHC_II_length      | 15                                         |                                |
|                | --MHC_II_alleles     | "/app/Resources/consensus3_alleles.txt"    |                                |   
|                |                      |                                            |                                |
-----------------------------------------------------------------------------------------------------------------------
```

**TEST PROFILES**
```bash
nextflow run main.nf -profile test_proteome --mode filtered
```
```bash
nextflow run main.nf -profile test_genome --mode filtered
```
```bash
nextflow run main.nf -profile test_batchgenome --mode filtered
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

This is my current github read me
