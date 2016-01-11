#!/usr/bin/bash 

####
#### POLYSNP
###
### le script qui effectue le base-calling via phred, qui détermine les
### positions de SNP qui sont aux positions attendues d'après les alignements de
### référence, et qui détermine pour chaque position attendue les deux bases
### appelées à chaque pic.

cd ~/stage/seq_novembre/data/tmp_snp

## copie l'alignement référence dans .
cp ../ref/aln-weak-wt.fst .

for spectro in ../spectrogrammes/pW*.ab1;
do
    cp $file .
    polySNP \
        -r aln-weak-wt.fst \
        -t $file \
        # base call and trim with phred
        -p 0 \
        # cutoff optionnel de trimming
        -c 0.05
    rm ./`basename $file`
done
