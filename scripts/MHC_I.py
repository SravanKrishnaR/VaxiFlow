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

Alleles = [
    "HLA-A01:01", "HLA-A02:01", "HLA-A02:03", "HLA-A02:06", "HLA-A03:01", "HLA-A11:01", "HLA-A23:01", "HLA-A24:02",
    "HLA-A26:01", "HLA-A30:01", "HLA-A30:02", "HLA-A31:01", "HLA-A32:01", "HLA-A33:01", "HLA-A68:01", "HLA-A68:02",
    "HLA-B07:02", "HLA-B08:01", "HLA-B15:01", "HLA-B35:01", "HLA-B40:01", "HLA-B44:02", "HLA-B44:03", "HLA-B51:01",
    "HLA-B53:01", "HLA-B57:01", "HLA-B58:01"
]
kmers = [8, 9, 10, 11]

# Create dataframe of all kmers with parent protein IDs
kmer_records = []
records = list(SeqIO.parse("cleaned_proteins.fasta", "fasta"))

for i in kmers:
    for record in records:
        seq = record.seq
        for j in range(len(seq) - i + 1):
            kmer = str(seq[j:j+i])
            kmer_records.append({"protein_id": record.id, "peptide": kmer})

kmer_df = pd.DataFrame(kmer_records)
kmer_df.to_csv("all_kmers_with_id.csv", index=False)

# Write only peptides for mhcnuggets
kmer_df["peptide"].to_csv("all_kmers.txt", index=False, header=False)

# Run prediction per allele and merge with protein IDs
all_filtered = []
for allele in Alleles:
    output_file = f"temp_predictions_{allele.replace('*', '').replace(':', '')}.csv"

    predict(
        class_='I',
        peptides_path='all_kmers.txt',
        mhc=allele,
        output=output_file,
        rank_output=True
    )

    df = pd.read_csv(output_file)
    df_filtered = df[df.ic50 < 500].copy()
    df_filtered["allele"] = allele

    # Merge back protein_id
    df_filtered = df_filtered.merge(kmer_df, on="peptide", how="left")

    all_filtered.append(df_filtered)

    # Cleanup
    for f in [
        output_file,
        output_file.replace('.csv', '_ranks.csv'),
        "mhcnuggets_predictions.csv",
        "mhcnuggets_predictions_ranks.csv"
    ]:
        if os.path.exists(f):
            os.remove(f)

# Final output with protein IDs
final_df = pd.concat(all_filtered, ignore_index=True)
final_df = final_df[["protein_id", "peptide", "ic50", "allele"]]
final_df.to_csv("filtered_predictions_classI.csv", index=False)
