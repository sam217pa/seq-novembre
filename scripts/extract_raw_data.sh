#!/bin/bash 

# Le script qui extrait les données depuis les fichiers zip bruts et qui met en
# place la structure de fichier.

cd ./data # cd ../data quand dans dossier `scripts'
# extraction des données brutes
unzip raw_seq_nvbr/1369607.zip
unzip raw_seq_nvbr/1369628.zip
# déplace tout les fichiers dans des dossiers adaptés 
find . -name "*.fas" -exec mv -i {} -t ./fasta/ \;
find . -name "*.ab1" -exec mv -i {} -t ./spectrograms/ \;
find . -name "*.seq" -exec mv -i {} -t ./seq/ \;
# déplace le contenu du dossier inutile dans le présent dossier
mv 1369628/* ./
rm -r 1369628 # supprime le dossier

##
## supprime fichiers mauvaise qualité
##
# absence de données dans pS6-1073.fas

##
## combine tout les fasta en 1
##
if [ -f all.fasta ]
then
    rm all.fasta
    echo "Cleaning old files"
    touch all.fasta
else
    touch all.fasta
fi

cat ../data/fasta/*.fas >> ../data/all.fasta
