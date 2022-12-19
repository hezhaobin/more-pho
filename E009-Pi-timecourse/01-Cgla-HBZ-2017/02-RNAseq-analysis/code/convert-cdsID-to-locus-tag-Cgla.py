"""Parse the transcript IDs in the BG2 cds file into locus tags for analysis
   Bin He
   2022-11-16
"""

# import libraries
from Bio import SeqIO
import sys
import re


IN = "../data/annotation/GCA_014217725.1_ASM1421772v1_cds_from_genomic.fna.gz"
OUT = "../data/annotatiion/GCA_014217725.1-cdsID-to-locus-tag.txt"

# read in fasta and turn it into a dictionary https://biopython.org/wiki/SeqIO
with open(FA, "r") as FH:
    fasta_records = SeqIO.to_dict(SeqIO.parse(FH, "fasta"))

# create a container for filtered results
filtered = []

# iterate through the FungalRV result file
with open(IN, "r") as f:
    for name in f:
        filtered.append(fasta_records[name.rstrip()])

SeqIO.write(filtered, OUT, "fasta")
