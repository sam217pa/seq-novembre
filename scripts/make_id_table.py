from Bio import SeqIO
import glob

def mutant_qualifier(record):
    if 'S' in record:
        return 'strong'
    else:
        return 'weak'

print "id name mutant"
for file in glob.glob("../data/spectrograms/*.ab1"):
    with open(file, "rb") as spectro:
        for record in SeqIO.parse(spectro, "abi"):
            print record.id + " " + record.name + \
                " " + mutant_qualifier(record.name)
