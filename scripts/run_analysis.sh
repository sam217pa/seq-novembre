cd ~/stage/seq_novembre/scripts

chmod +x *.sh

./extract_raw_data                             # extrait les données des .zip et
                                               # organise en sous fichiers
./ab1_to_fastq.sh                              # extrait les fastq et fasta
                                               # depuis les .ab1
./trim_low_quality.sh                          # supprime les données de faible
                                               # qualité et transforme les bases
                                               # de qualité inférieure à 28 en N
./quality_check.sh                             # analyse fastqc, crée les
                                               # graphes en png et sortie des
                                               # html dans le dossier analysis
./variantCallerSsaha2.sh                       # détermine la position des SNP
                                               # basé sur la référence
python make_id_table.py > ../data/id_table.dat # crée la table d'association des
                                               # identifiants de séquence avec
                                               # le nom des clones
Rscript variant_analysis.R                     # analyses et graphiques dans ce
                                               # script
