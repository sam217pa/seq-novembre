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

fastq_to_fasta -i ../data/untrimmed.fastq -o ../data/untrimmed.fasta
