#!/bin/bash

# NOT RUN : mkdir snp-calling snp-calling/weak snp-calling/strong

cd ~/stage/seq_novembre/data/snp-calling

# crée la table de résultat pour weak et strong.
../../scripts/polysniper-weak.sh > weak/weak-polysnp.csv
../../scripts/polysniper-strong.sh > strong/strong-polysnp.csv

# enlève les lignes vides dans les deux fichiers.
sed -i '/^$/d' weak/weak-polysnp.csv
sed -i '/^$/d' strong/strong-polysnp.csv

# enlève les champs mal formattés (ie une virgule dans le champ commentaire.
# dans un fichier csv. malin...)
sed 's/,\ / /g' weak/weak-polysnp.csv > weak/weak-polysnp.tmp.csv
sed 's/,\ / /g' strong/strong-polysnp.csv > strong/strong-polysnp.tmp.csv

# prepend header.csv describing fields to results table
cat header.csv weak/weak-polysnp.tmp.csv > weak.csv
cat header.csv strong/strong-polysnp.tmp.csv > strong.csv
