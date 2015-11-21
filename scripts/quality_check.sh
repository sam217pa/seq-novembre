#!/usr/local/bin/bash
cd ~/stage/seq_novembre/scripts

# quand dans le dossier ./scripts
cd ../data/

if [ -f untrimmed.fastq ] && [ -f trimmed.fastq ] ; then
    mkdir tmp
    # analyse les données et output dans tmp
    fastqc untrimmed.fastq -o ./tmp
    fastqc trimmed.fastq   -o ./tmp
    # unzip resulting files
    unzip -qq tmp/untrimmed_fastqc.zip -d tmp
    unzip -qq tmp/trimmed_fastqc.zip -d tmp
    # extract main results
    mv tmp/untrimmed_fastqc/Images/per_base_quality.png \
       ../analysis/per_base_quality_fastqc_untrimmed.png
    mv tmp/trimmed_fastqc/Images/per_base_quality.png \
       ../analysis/per_base_quality_fastqc_trimmed.png
    # copy html into analysis
    mv tmp/*.html ../analysis/
    # delete tmp files
    rm -r tmp # remove temporary files

else
    printf "Les fichiers untrimmed.fastq et trimmed.fastq n'existent pas."
fi
