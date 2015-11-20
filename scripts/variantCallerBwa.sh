#!/bin/bash

# le but est de déterminer les SNP
# le workflow suivi est celui décrit là http://www.htslib.org/workflow/. 

## working dir
cd ../data
mkdir variantCalling

## utilise le reverse complement de la séquence de référence
fastx_reverse_complement -i refseq.fasta -o refseq_reverse.fasta
cp refseq_reverse.fasta variantCalling/
cp trimmed.fastq variantCalling/

cd variantCalling
# renome en utilisant un nom plus simple
mv refseq_reverse.fasta reference.fasta
## indexation du fichier référence
bwa index reference.fasta
# alignement au fichier de reference
#' * aln : align
#' * mem : algo bwa-mem, more accurate with reads > 100bp. 
#' * reference.fasta : reference sequence
#' * trimmed.fastq : sequence trimmee.
#' * aln_sa.sai : fichier aligné indexé
bwa mem reference.fasta trimmed.fastq > align.sam

## sort from name order to coordinate order
#' * sort : sorting algorithm
#' * -O bam : output to bam
#' * -o align.bam : name of output
#' * -T ./tmp/align_temp : name of temp file
#' * align.sam : fichier en entrée
mkdir tmp
samtools sort -O bam -o align.bam -T ./tmp/align_temp align.sam

## conversion au format sam
#' * samse : sam singled end
#' * reference.fasta : reference sequence
#' * aln_sa.sai : alignement indexé
# bwa samse reference.fasta aln_sa.sai trimmed.fastq > aln.sam

## variant calling
#'
#'
samtools mpileup -ugf reference.fasta align.bam | \
    bcftools call -vmO z -o study.vcf.gz

## indexation du VCF
tabix -p vcf study.vcf.gz

## graphes et statistiques
bcftools stats -F reference.fasta -s - study.vcf.gz > study.vcf.gz.stats
mkdir plots
plot-vcfstats -p plots/ study.vcf.gz.stats
## déplace dans le dossier analyses
cp -r plots ../../analysis/
