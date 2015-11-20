cd ~/stage/seq_novembre/scripts

for file in ../data/spectrograms/*.ab1
do
    seqret -sformat abi -osformat fastq -auto -stdout -sequence $file > ../data/untrimmed.fastq
    seqret -sformat abi -osformat fasta -auto -stdout -sequence $file > ../data/untrimmed.fasta
done
