args = commandArgs(trailingOnly=TRUE)

orig_seqs <- args[1]
fixed_seqs <- args[2]


####

library(seqinr)


##### Check for two types of gap in 300 and vp1 seqs
# It'll process this for full-genome too but it won't fix it currently...
# This should be replaced by a codon-aware alignment method, which will solve this problem.

seqs <- read.fasta(orig_seqs, as.string=T, forceDNAtolower=F)
seq_names <- attr(seqs,"name")

#Gap type number 1
withGap <- grep("G---TAA", seqs)

countr <- 0
for(wG in withGap){
    seq <- seqs[[wG]][1]
    findr <- regexpr("G---TAA", seq) #should be at 425
    if(findr == 425){
        newSeq <- gsub("G---TAA","GT---AA", seq)
        seqs[[wG]][1] <- newSeq
        countr = countr+1
    }
}
print(paste("replaced",countr,"type 1 gaps"))

#Gap type number 2

withGap <- grep("A---A", seqs)

countr <- 0
for(wG in withGap){
    seq <- seqs[[wG]][1]
    findr <- regexpr("A---A", seq) #should be at 427
    if(427 %in% findr[[1]]){
        newSeq <- gsub("A---A","---AA", seq)
        seqs[[wG]][1] <- newSeq
        countr = countr+1
    }
}
print(paste("replaced",countr,"type 2 gaps"))


#Gap type number 3
withGap <- grep("---G", seqs)

countr <- 0
for(wG in withGap){
    seq <- seqs[[wG]][1]
    findr <- gregexpr("---G", seq) #should be at 419
    if(419 %in% findr[[1]]){
        newSeq <- sub("A---G","---AG", seq)
        newSeq <- sub("G---G","---GG", newSeq)
        seqs[[wG]][1] <- newSeq
        countr = countr+1
    }
}
print(paste("replaced",countr,"type 3 gaps"))

write.fasta(seqs, seq_names, file.out=fixed_seqs, nbchar=10000)


