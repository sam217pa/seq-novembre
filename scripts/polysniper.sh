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
# prepend header.csv describing fields to results
# table and remove space
{ head -n 1 header.csv |          \
        sed 's/ /\./g' ;          \
  cat weak/weak-polysnp.csv |     \
      sed 's/,\ / /g' }  |        \
    cat > weak.csv

{ head -n 1 header.csv |          \
        sed 's/ /\./g' ;          \
  cat strong/strong-polysnp.csv | \
      sed 's/,\ / /g' } |         \
    cat > strong.csv
