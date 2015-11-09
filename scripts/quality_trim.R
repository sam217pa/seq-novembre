library(ShortRead)
library(ggplot2)
fls <- dir("./data/tmp", "*fastq$", full=TRUE)
qaSummary <- qa(fls, type="fastq")
browseURL(report(qaSummary))

filterAndTrim <-
    function(fl, destination = sprintf("%s-subset", fl)) {
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

fastq <- readFastq(dirPath = "./data/fastq", pattern = "*fastq$")
quality(fastq)
qplot(width(fastq), geom = "density")
