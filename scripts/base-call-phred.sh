#!/usr/local/bin/bash

#### PHRED BASE CALLING

### utilise phred pour le base call des spectrogrammes. Ce qui nous interésse
### ici n'est pas tant le base call en soi que les contrôles de qualité et
### surtout la détection des bases polymorphes.

cd ~/stage/seq_novembre/data/

# NOT RUN : mkdir quality phred poly

phred \
    ## emplacement des fichiers
    -id ./spectrograms \
    ## trim les bases à gauche et droite en fonction de la qualité
    -trim_alt \
    ## selon la probabilité d'erreur suivante.
    -trim_cutoff 0.05 \
    ## écrit les séquences trimmées dans un fichier phred
    -trim_phd \
    ## sortie des fichiers de qualité dans le dossier quality au format .qual
    -qd ./quality \
    ## sortie des séquences dans le dossier quality au format .qual
    -pd ./phred \
    ## sortie des positions polymporphiques dans le dossier poly.
    -dd ./poly
