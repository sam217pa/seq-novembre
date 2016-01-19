#!/bin/bash 

####
#### POLYSNP
####
###
### Ce script qui effectue le base-calling via phred, détermine les
### positions de SNP qui sont aux positions attendues d'après les alignements de
### référence, et détermine pour chaque position attendue les deux bases
### appelées à chaque pic.

cd ~/stage/seq_novembre/data/snp-calling/weak

## copie l'alignement référence dans .
cp ../../ref/aln-weak-wt.fst .

for spectro in ../../spectrograms/pW*.ab1
do
    cp $spectro .
    polySNP \
        -r aln-weak-wt.fst \
        -t `basename $spectro` \
        -p 0 \
        -c 0.05
    rm ./`basename $spectro`
done
