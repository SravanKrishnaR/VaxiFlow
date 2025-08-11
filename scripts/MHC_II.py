from Bio import SeqIO
import pandas as pd
import subprocess
import os
from mhcnuggets.src.predict import predict
import argparse

parser = argparse.ArgumentParser(description="simple inputs")
parser.add_argument('-p', '--protein', type=argparse.FileType('r'), help='Input the file containing the protein')
args = parser.parse_args()
protein_file = args.protein.name

# Clean protein file
subprocess.run(f"sed 's/\\*//g' {protein_file} > cleaned_proteins.fasta", shell=True, check=True)

Alleles_II = [
"HLA-DRB1*01:01",
"HLA-DRB1*03:01",
"HLA-DRB1*04:01",
"HLA-DRB1*04:05",
"HLA-DRB1*07:01",
"HLA-DRB1*08:02",
"HLA-DRB1*09:01",
"HLA-DRB1*11:01",
"HLA-DRB1*12:01",
"HLA-DRB1*13:02",
"HLA-DRB1*15:01",
"HLA-DRB3*01:01",
"HLA-DRB3*02:02",
"HLA-DRB4*01:01",
"HLA-DRB5*01:01",
"HLA-DQA1*05:01",
"HLA-DQA1*05:01",
"HLA-DQA1*03:01",
"HLA-DQA1*04:01",
"HLA-DQA1*01:01",
"HLA-DQA1*01:02",
"HLA-DPA1*02:01",
"HLA-DPA1*01:03",
"HLA-DPA1*01:03",
"HLA-DPA1*03:01",
"HLA-DPA1*02:01",
"HLA-DPA1*02:01"
]

kmer_length = 15

kmer_records = []
records = list(SeqIO.parse("cleaned_proteins.fasta", "fasta"))

for record in records:
    seq = record.seq
    for j in range(len(seq) - kmer_length + 1):
        kmer = str(seq[j:j + kmer_length])
        kmer_records.append({"protein_id": record.id, "peptide": kmer})

kmer_df = pd.DataFrame(kmer_records)
kmer_df.to_csv("all_kmers_with_id.csv", index=False)
kmer_df["peptide"].to_csv("all_kmers.txt", index=False, header=False)

all_filtered = []
for allele in Alleles_II:
    output_file = f"temp_predictions_{allele.replace('*', '').replace(':', '').replace('-', '')}.csv"

    predict(
        class_='II',
        peptides_path='all_kmers.txt',
        mhc=allele,
        output=output_file,
        rank_output=True
    )

    df = pd.read_csv(output_file)
    df_filtered = df[df.ic50 < 500].copy()
    df_filtered["allele"] = allele
    df_filtered = df_filtered.merge(kmer_df, on="peptide", how="left")

    all_filtered.append(df_filtered)

    # Cleanup intermediate files
    for f in [
        output_file,
        output_file.replace('.csv', '_ranks.csv'),
        "mhcnuggets_predictions.csv",
        "mhcnuggets_predictions_ranks.csv"
    ]:
        if os.path.exists(f):
            os.remove(f)

final_df = pd.concat(all_filtered, ignore_index=True)
final_df = final_df[["protein_id", "peptide", "ic50", "allele"]]
final_df.to_csv("filtered_predictions_classII.csv", index=False)

