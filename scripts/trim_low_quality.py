#!/usr/bin/env python
import os
from Bio import SeqIO
import numpy as np

untrimmed_fastq = SeqIO.parse(open("../data/untrimmed.fastq", "rU"), "fastq")

# trim low quality sequence ends,
# keep only sequence where mean phred score is > 50
good_reads = (rec[30:-40] for rec in untrimmed_fastq \
              if np.mean(rec.letter_annotations["phred_quality"]) > 50 )

# output to disk
SeqIO.write(good_reads, "../data/trimmed.fastq", "fastq")

# run fastqc, with output to dir analysis
os.system("fastqc -o ../analysis ../data/trimmed.fastq")
os.system("fastqc -o ../analysis ../data/untrimmed.fastq")
