cd ~/stage/seq_novembre/scripts

touch untrimmed.fastq
for file in ../data/spectrograms/*.ab1
do
    seqret \
        -sformat abi \
        -osformat fastq \
        -auto \
        -stdout \
        -sequence $file \
        >> ../data/untrimmed.fastq
done

## convertit le fastq en fasta
seqret \
    -sformat fastq \
    -osformat fasta \
    -auto \
    -stdout \
    -sequence ../data/untrimmed.fastq \
    > ../data/untrimmed.fasta
