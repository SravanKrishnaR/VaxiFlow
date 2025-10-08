import requests
import pandas as pd
import io
import argparse
from Bio import SeqIO
import time

url = "http://tools-cluster-interface.iedb.org/tools_api/mhcii/"
r=requests.get(url)

parser=argparse.ArgumentParser(description="Input Data")
parser.add_argument('--input',type=argparse.FileType('r'),help="Input the fasta file with protein sequences")
args=parser.parse_args()

alleles = [
"HLA-DRB1*01:01","HLA-DRB1*03:01","HLA-DRB1*04:01","HLA-DRB1*04:05","HLA-DRB1*07:01","HLA-DRB1*08:02",
"HLA-DRB1*09:01","HLA-DRB1*11:01","HLA-DRB1*12:01","HLA-DRB1*13:02","HLA-DRB1*15:01","HLA-DRB3*01:01",
"HLA-DRB3*02:02","HLA-DRB4*01:01","HLA-DRB5*01:01","HLA-DQA1*05:01/DQB1*02:01","HLA-DQA1*05:01/DQB1*03:01",
"HLA-DQA1*03:01/DQB1*03:02","HLA-DQA1*04:01/DQB1*04:02","HLA-DQA1*01:01/DQB1*05:01","HLA-DQA1*01:02/DQB1*06:02",
"HLA-DPA1*02:01/DPB1*01:01","HLA-DPA1*01:03/DPB1*02:01","HLA-DPA1*01:03/DPB1*04:01","HLA-DPA1*03:01/DPB1*04:02",
"HLA-DPA1*02:01/DPB1*05:01","HLA-DPA1*02:01/DPB1*14:01",]
lengths = [15]

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
            response = requests.post(url, data=data)
        
            try:
                df = pd.read_csv(io.StringIO(response.text), sep="\t")
                if df.shape[0] > 0:
                    results.append(df)

            except Exception as e:
                print(f"Could not parse {allele} ({length}-mer): {e}")

            time.sleep(5)

    if results:
        final_df = pd.concat(results, ignore_index=True)
        final_df.to_csv(f"{record.id}.csv", index=False)