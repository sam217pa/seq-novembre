#!/bin/bash 

cd ~/stage/seq_novembre/
# Le script qui extrait les données depuis les fichiers zip bruts et qui met en
# place la structure de fichier.

cd ./data
## extraction des données brutes
unzip raw_seq_nvbr/1369607.zip
unzip raw_seq_nvbr/1369628.zip

## crée les dossiers
mkdir fasta seq spectrograms csv
## déplace tout les fichiers dans des dossiers adaptés 
find . -name "*.fas" -exec mv -i {} -t ./fasta/ \;
find . -name "*.ab1" -exec mv -i {} -t ./spectrograms/ \;
find . -name "*.seq" -exec mv -i {} -t ./seq/ \;
find . -name "*.csv" -exec mv -i {} -t ./csv/ \;

# déplace le contenu du dossier inutile dans le présent dossier
mv 1369628/* ./
rm -r 1369628 # supprime le dossier
# déplace le fichier pdf dans le dossier adapté
mv *.pdf ../analysis
