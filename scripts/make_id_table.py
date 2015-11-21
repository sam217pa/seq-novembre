from Bio import SeqIO
import glob

def strong_or_weak(record):
    """
    Determine si le mutant est strong ou weak
    """
    if 'S' in record:
        return 'strong'
    else:
        return 'weak'

# en-tete de colonne
print "id name mutant"

# pour chaque fichier ab1
for file in glob.glob("../data/spectrograms/*.ab1"):
    with open(file, "rb") as spectro:
        for record in SeqIO.parse(spectro, "abi"):
            # associer l'id avec le nom et le type de mutant
            print record.id + " " + record.name + \
                " " + strong_or_weak(record.name)
