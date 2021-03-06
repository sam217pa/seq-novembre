#!/bin/bash 

####
#### POLYSNP
###
### le script qui effectue le base-calling via phred, qui détermine les
### positions de SNP qui sont aux positions attendues d'après les alignements de
### référence, et qui détermine pour chaque position attendue les deux bases
### appelées à chaque pic.

cd ~/stage/seq_novembre/data/snp-calling/strong

## copie l'alignement référence dans .
cp ../../ref/aln-strong-wt.fst .

for spectro in ../../spectrograms/pS*.ab1
do
    cp $spectro .
    polySNP \
        -r aln-strong-wt.fst \
        -t `basename $spectro` \
        -p 0 \
        -c 0.05
    rm ./`basename $spectro`
done
