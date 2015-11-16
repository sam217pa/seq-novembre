library(ShortRead)
library(ggplot2)

filterAndTrim <- function(fl, destination = sprintf("%s-subset", fl)) {
    ## open input stream
    stream <- open(FastqStreamer(fl))
    on.exit(close(stream))

    repeat {
        ## input chunk
        fq <- yield(stream)
        if (length(fq) == 0)
            break
        ## trim and filter, e.g. reads cannot contain 'N'
        fq <- fq[nFilter()(fq)] # see ?srFilter for predefined filters
        ## trim as soon as 2 of 5 ncleotides has quality encoding less
        ## than "4" (phred score 20)
        fq <- trimTailw(fq, 2, "4", 2)
        ## drop reads that are less than 36 nt
        fq <- fq[width(fq) >= 36]

        ## append to destination
        writeFastq(fq, destination, "a")
    }
}

fastq <- readFastq(dirPath = "../data/fastq", pattern = "*fastq$")
qplot(width(fastq), geom = "density")
quality(fastq)
qual <- PhredQuality(quality(quality(fastq)))
qual
myqual_mat <- matrix(charToRaw(as.character(unlist(qual))), nrow=length(qual), byrow=TRUE) # convert quality score to matrix
at <- myqual_mat < charToRaw(as.character(PhredQuality(as.integer(qualityCutoff)))) # find positions of low quality
letter_subject <- DNAString(paste(rep.int("N", width(seqs)[1]), collapse="")) # create a matrix of Ns
letter <- as(Views(letter_subject, start=1, end=rowSums(at)), "DNAStringSet") # trim to length needed for each read
injectedseqs <- replaceLetterAt(seqs, at, letter) # inject Ns at low quality positions
