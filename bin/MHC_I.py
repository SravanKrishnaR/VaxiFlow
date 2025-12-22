#!/usr/bin/env python3
import requests
import pandas as pd
import io
import argparse
from Bio import SeqIO
import time

url="https://tools-cluster-interface.iedb.org/tools_api/mhci/"
r=requests.get(url)

parser=argparse.ArgumentParser(description="Input Data")
parser.add_argument('--input',type=argparse.FileType('r'),help="Input the fasta file with protein sequences")
args=parser.parse_args()

alleles = [
    "HLA-A*01:01","HLA-A*02:01","HLA-A*02:03","HLA-A*02:06",
    "HLA-A*03:01","HLA-A*11:01","HLA-A*23:01","HLA-A*24:02",
    "HLA-A*26:01","HLA-A*30:01","HLA-A*30:02","HLA-A*31:01",
    "HLA-A*32:01","HLA-A*33:01","HLA-A*68:01","HLA-A*68:02",
    "HLA-B*07:02","HLA-B*08:01","HLA-B*15:01","HLA-B*35:01",
    "HLA-B*40:01","HLA-B*44:02","HLA-B*44:03","HLA-B*51:01",
    "HLA-B*53:01","HLA-B*57:01","HLA-B*58:01"
]
lengths = [9, 10]

for record in SeqIO.parse(args.input, "fasta"):
    print((f">{record.id}\n{record.seq}"))
    results = []

    for allele in alleles:
        for length in lengths:
            data = {
                "method": "recommended",
                "sequence_text": str(record.seq),
                "allele": allele,
                "length": str(length)
                }

            print(f"Processing {allele} ({length}-mer)")
            response = requests.post(url, data=data, timeout=60)

            try:
                df = pd.read_csv(io.StringIO(response.text), sep="\t")
                if df.shape[0] > 0:
                    results.append(df)

            except Exception as e:
                print(f"Unable to parse {allele} ({length}-mer): {e}")

            time.sleep(5)

    if results:
        final_df = pd.concat(results, ignore_index=True)

        final_df.to_csv(f"{record.id}.csv", index=False)
