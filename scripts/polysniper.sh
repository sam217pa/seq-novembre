#!/bin/bash

# NOT RUN : mkdir snp-calling snp-calling/weak snp-calling/strong

cd ~/stage/seq_novembre/data/snp-calling

# crée la table de résultat pour weak et strong.
../../polysniper-weak.sh > weak/weak_polysnp.csv
../../polysniper-strong.sh > strong/strong_polysnp.csv

# enlève les lignes vides dans les deux fichiers.
sed -i '/^$/d' weak/weak_polysnp.csv
sed -i '/^$/d' strong/strong_polysnp.csv
