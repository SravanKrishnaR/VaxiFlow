#!/usr/bin/env python3

import argparse
from Bio import SeqIO
from Bio.SeqUtils.ProtParam import ProteinAnalysis

def analyze_protein(seq, seq_id="unknown"):
    prot = ProteinAnalysis(str(seq))
    aa_percent = prot.get_amino_acids_percent()

    # Aliphatic index formula (Ikai, 1980)
    AI = (
        aa_percent["A"]*100 +
        aa_percent["V"]*100*2.9 +
        aa_percent["I"]*100*3.9 +
        aa_percent["L"]*100*3.9
    )

    print(f"\n=== Results for {seq_id} ===")
    print("Length:", len(seq))
    print("Molecular weight:", f"{prot.molecular_weight():.2f}")
    print("Isoelectric point (pI):", f"{prot.isoelectric_point():.2f}")
    print("GRAVY:", f"{prot.gravy():.3f}")
    print("Instability index:", f"{prot.instability_index():.2f}")
    print("Aromaticity:", f"{prot.aromaticity():.3f}")
    print("Aliphatic index:", f"{AI:.2f}")


def main():
    parser = argparse.ArgumentParser(
        description="Compute physicochemical properties of proteins"
    )
    parser.add_argument(
        "-p", "--proteins",
        required=True,
        help="Input protein FASTA file"
    )
    args = parser.parse_args()

    # Read sequences from FASTA
    for record in SeqIO.parse(args.proteins, "fasta"):
        analyze_protein(record.seq, record.id)


if __name__ == "__main__":
    main()
