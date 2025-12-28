# VaxiFlow
VaxiFlow, An automated Nextflow based pipeline for reverse vaccinology that streamlines vaccine candidate discovery through comprehensive antigen prediction, filtering, and prioritization workflows.

**Overview**:<br>
VaxiFlow automates genome and proteome processing through multi-stage antigen filtering using established immunoinformatics tools. The pipeline supports single genome, multi-genome, and proteome-based analyses and is fully containerized to ensure reproducibility across computing environments.  

**Tools and Packages Used**:<br>
**PROKKA** – Annotating genomes (For both single and batch genome analysis)<br>
**ROARY** – Pangenome analysis (Only for batch genome analysis)<br>

**Shared Downstream Analysis**:<br>
**DIAMOND** - Aligning protein and translated DNA sequences against large databases<br>
**VFDB** – Virulence factor screening on VFDB database via DIAMOND BLAST<br>
**Human Homolog screening** – Host similarity detection via DIAMOND BLAST<br>
**ALGPRED** – Allergenicity prediction<br>
**SIGNALP** – Signal peptide detection<br>
**DEEPLOCPRO** – Subcellular localization prediction<br>
**TOXINPRED** – Toxicity prediction<br>
**DEEPTHMMM** – Transmembrane helix filtering (≤ 1 helix)<br>
**IEDB RESTful API** – MHC class I and II epitope prediction<br>
**Bio.SeqUtils.ProtParam** - Extract useful protein parameters

# Usage
**HELP**:
Check parameters using:
```bash
nextflow run SravanKrishnaR/VaxiFlow --help 
```

**Requirements:**<br>
`Nextflow` 
`Docker` 
`conda`

**MODES:**<br>
EACH OUTPUT GETS FILTERED<br>
```bash
--filtered
```
RUN EACH TOOL INDIVIDUALLY<br>
```bash
--unfiltered
```

**FOR PROTEOME ANALYSIS**:
```bash
nextflow run SravanKrishnaR/VaxiFlow \
 --proteome \
 <input data> \
 --<parameters> \
 --unfiltered 
```

**FOR MULTI-GENOME ANALYSIS**:
```bash
nextflow run SravanKrishnaR/VaxiFlow \
 --genomes \
 <input data> \
 --<parameters> \
 --unfiltered
```

**FOR SINGLE GENOME ANALYSIS**:
```bash
nextflow run SravanKrishnaR/VaxiFlow \
 --genome \
 <input data> \
 --<parameters> \
 --unfiltered
```

<img width="2550" height="1986" alt="Image" src="https://github.com/user-attachments/assets/ba09b30e-29a4-4947-a35f-81f5e2f6b9fe" />

**Pipeline Configuration Parameters**
|Parameter       | Default Value    | 
|----------------|------------------|
|--cpus            |12              |               
|--memory          |8 GB            |               
|--outdir          |Results         |               
|--publish_mode    |copy            |
|--pipeline_report |pipeline_report |
|--monochrome_logs |false           |

**ROARY**
|Parameter       | Default Value  |
|----------------|----------------|
|--identity        |95            |

**CD-HIT**
|Parameter          | Default Value  |
|-------------------|----------------|
|--SequenceIdentity |0.9             |
|--WordLength       |5               |
|--DescpLength      |0               |

**PROKKA**
|Parameter         | Default Value  |Custom Value                   |
|------------------|----------------|--------------------------------
|--kingdom         |Bacteria        |Archaea, Mitochondria, Viruses |
|--gram            |neg             |pos, ''                        |

**TOXINPRED**
|Parameter          |Default Value   |Custom Value                   |
|-------------------|----------------|--------------------------------
|--threshold        |0.38            |0 to 1                         |
|--model            |1               |1:AAC & DPC based ET, 2:Hybrid |
|--toxinpredDisplay |2               |1:Toxin, 2:All peptides        |

**DEEPLOCPRO**
|Parameter         |Default Value   |Custom Value                   |
|------------------|----------------|--------------------------------
|--group           |negative        |archaea,positive               |
|--device          |cpu             |cuda, mps                      |

**ALGPRED**
|Parameter         |Default Value   |Custom Value                   |
|------------------|----------------|--------------------------------
|--threshold       |0.3             |0 to 1                         |
|--model           |1               |1:Allergen, 2:Non-Allergen     |
|--algpredDisplay  |1               |1:Allergen, 2:All peptides     |

**SIGNALP**
|Parameter         |Default Value   |Custom Value                   |
|------------------|----------------|--------------------------------
|--organism        |other           |eukarya                        |
|--format          |txt             |png,eps,all,none               |
|--signalpMode     |fast            |slow,slow-sequential           |


**TEST PROFILES**
```bash
nextflow run SravanKrishnaR/VaxiFlow -profile test_proteome --mode unfiltered
```
```bash
nextflow run SravanKrishnaR/VaxiFlow -profile test_genome --mode unfiltered
```
```bash
nextflow run SravanKrishnaR/VaxiFlow -profile test_batchgenome --mode unfiltered
```

## Credits
This pipeline integrates several third-party tools and databases. I gratefully acknowledge the authors and maintainers of the following resources:

- **VFDB** (Virulence Factors Database)  
  VFDB 2022: a general classification scheme for bacterial virulence factors   
  Website: https://www.mgc.ac.cn/VFs/

- **HUMAN GENOME** (NCBI BLAST Human Protein Database)  
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

- **ProtParam**
  Biopython Project (2024). Bio.SeqUtils.ProtParam Documentation. Retrieved from Biopython. 
  Website: https://biopython.org/docs/1.76/api/Bio.SeqUtils.ProtParam.html
  Website: https://web.expasy.org/protparam/

- **IEDB RESTful API**
  Vita R, Blazeska N, Marrama D;  IEDB Curation Team Members; Duesing S, Bennett J, Greenbaum J, De Almeida Mendes M, Mahita J, Wheeler DK, Cantrell JR, Overton JA, Natale DA, Sette A, Peters B. The Immune Epitope Database (IEDB):    2024 update. Nucleic Acids Res. 2025 Jan 6;53(D1):D436-D443. doi: 10.1093/nar/gkae1092. PMID: 39558162; PMCID: PMC11701597.
  Website: www.iedb.org
  Website: https://tools.iedb.org/main/tools-api/
