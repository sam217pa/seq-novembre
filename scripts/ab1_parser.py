#!/usr/bin/env python
import sys
import os
from Bio import SeqIO


# lit tout les fichiers du dossiers
for file_name in os.listdir("../data/spectrograms/"):
    # check if it ends with .ab1
    if file_name.endswith(".ab1"):
        print("reading sequences from " + file_name)
        
        ab1_in = "../data/spectrograms/" + file_name
        fastq_out = "../data/fastq/" + file_name[0:-4] + ".fastq"
        # convert the file
        SeqIO.convert(ab1_in, "abi", fastq_out, "fastq")
