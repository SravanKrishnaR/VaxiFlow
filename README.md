# VaxiFlow
VaxiFlow, An automated Nextflow based pipeline for protein prioritization through reverse vaccinology methodology that streamlines vaccine candidate discovery.

**Requirements:**
`Nextflow >= 25.04.6.5954` 
`Docker` 

**HELP**
```bash
nextflow run SravanKrishnaR/VaxiFlow --help
```

**FOR PROTEOME ANALYSIS**
```bash
nextflow run SravanKrishnaR/VaxiFlow --proteome <input data> <parameters> -profile docker/singularity
```

**FOR GENOME ANALYSIS**
```bash
nextflow run SravanKrishnaR/VaxiFlow --genome <input data> <parameters> -profile docker/singularity
```

**FOR PANGENOME ANALYSIS**
```bash
nextflow run SravanKrishnaR/VaxiFlow --pangenome <input data> <parameters> -profile docker/singularity
```

**MODES:**<br>
RUN CANDIDATES AGAINST EACH TOOL INDIVIDUALLY (default)
```bash
--mode unfiltered
```

EACH OUTPUT GETS FILTERED
```bash
--mode filtered
```

<img width="2588" height="1941" alt="Image" src="https://github.com/user-attachments/assets/673947a3-51a1-47c2-a53e-8d6c5a3acfb5" />

**Pipeline Configuration Parameters**
```
Parameter             Default Value  
--cpus                12                    
--memory              8 GB                           
--outdir              Results                        
--publish_mode        copy            
--pipeline_report     pipeline_report 
--monochrome_logs     false
--mode                unfiltered
```

| Tool           | Parameter            | Default value                              | Values                                       |
|----------------|----------------------|--------------------------------------------|----------------------------------------------|
| ROARY          | --identity           | 95                                         | 95                                           |
|                |                      |                                            |                                              |
| CD-HIT         | --SequenceIdentity   | 0.9                                        |                                              |
|                | --WordLength         | 5                                          |                                              |
|                | --DescpLength        | 0                                          |                                              |
|                |                      |                                            |                                              |
| PROKKA         | --kingdom            | Bacteria                                   | Bacteria, Archaea, Mitochondria, Viruses     |
|                |                      |                                            |                                              |
| TOXINPRED      | --threshold          | 0.38                                       | 0–1                                          |
|                | --model              | 1                                          | 1, 2                                         |
|                |                      |                                            |                                              |
| DEEPLOCPRO     | --group              | negative                                   | negative, archaea, positive                  | 
|                | --device             | cpu                                        | cpu, cuda, mps                               |
|                |                      |                                            |                                              |
| ALGPRED        | --threshold          | 0.3                                        | 0–1                                          |
|                |                      |                                            |                                              |
| SIGNALP        | --organism           | other                                      | eukarya, other                               |
|                | --signalpMode        | fast                                       | fast, slow, slow-sequential                  |
|                |                      |                                            |                                              |
| HUMAN_HOMOLOGS | --homologsdb         | '/app/human_db.dmnd'                       | users can provide thier custom database      |
|                |                      |                                            |                                              |
| VFDB           | --vfdb               | '/app/VFDB_db.dmnd'                        | users can provide thier custom database      |
|                |                      |                                            |                                              | 
| MHC_I          | --MHC_I_method       | ann                                        | ann, netmhcpan_el, netmhcpan_ba              |
|                | --MHC_I_length       | 11                                         |                                              |
|                | --MHC_I_alleles      | "/app/Resources/ann_human_allele.txt"      |                                              |
|                |                      |                                            |                                              |
|  MHC_II        | --MHC_II_method      | consensus3                                 | consensus3, comblib, smm_align, nn_align,    |
|                |                      |                                            | sturniolo, netmhciipan_el, netmhciipan_ba,   | 
|                |                      |                                            | netmhciipan_el-4.3, netmhciipan_el-4.2,      |
|                |                      |                                            | netmhciipan_ba-4.3, netmhciipan_ba-4.2       |
|                | --MHC_II_length      | 15                                         |                                              |
|                | --MHC_II_alleles     | "/app/Resources/consensus3_alleles.txt"    | users can provide thier custom alleles       |



**TEST PROFILES**
```bash
nextflow run SravanKrishnaR/VaxiFlow -profile test_proteome,docker
```
```bash
nextflow run SravanKrishnaR/VaxiFlow -profile test_genome,docker 
```
```bash
nextflow run SravanKrishnaR/VaxiFlow -profile test_pangenome,docker 
```
