#!/usr/bin/env python
import os
from Bio import SeqIO
import numpy as np

untrimmed_fastq = SeqIO.parse(open("untrimmed.fastq", "rU"), "fastq")

quality_min  = []
quality_mean = []
quality_max  = []

for record in untrimmed_fastq:
    # print("analysing seq with id : %s " % rec.id )
    # replace base with `N` if quality < X
    quality = 80
    rec = record[30:-30]
    # for phred in rec.letter_annotations["phred_quality"]:
    #     if phred < quality:
    #         print phred
        # print base.letter_annotation["phred_quality"]
    quality_min.append(     min(rec.letter_annotations["phred_quality"]))
    quality_max.append(     max(rec.letter_annotations["phred_quality"]))
    quality_mean.append(np.mean(rec.letter_annotations["phred_quality"]))
