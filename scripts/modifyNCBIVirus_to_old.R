#!/usr/bin/env Rscript 

# Load necessary library
library(data.table)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
    stop("Two arguments must be supplied (input file (csv), output file (tsv)).n", call.=FALSE)
} else {
    input <- args[1]
    output <- args[2]
}

data <- fread(input)

# If you can't run R command line, you can copy this code into R line by line, just comment the above lines and uncomment the following lines
# Be sure to also adjust the file names to match your own, and uncomment for 'genome' or 'vp1' as appropriate

# library(data.table)
# #genome
# setwd("C:/...../genome/data")
# # Read the CSV file
# data <- fread("sequences-NCBIVirus-2024-04-26_raw.csv")
# output <- "sequences-NCBIVirus-2024-04-26.tsv"
# 
# 
# #vp1
# setwd("C:/....../vp1/data")
# # Read the CSV file
# data <- fread("sequences-NCBIVirus-2024-05-01_raw.csv")
# output <- "sequences-NCBIVirus-2024-05-01.tsv"


# Reorder and rename columns
data_transformed <- data[, .("Strain Name" = GenBank_Title,
                             "Virus Type" = Species,
                             "GenBank Accession" = Accession,
                             "SequenceLength" = Length,
                             "Pango Genome Lineage" = "-NA-",
                             "Collection Date" = Collection_Date,
                             "Host" = "Human",
                             "GenBank Host" = Host,
                             "Country" = Country,
                             "Mol Type" = "genomic RNA")]

#try to get strain name
fixing <- data_transformed[,"Strain Name"][[1]]
fixing <- gsub("Enterovirus D68 isolate ", "", fixing)
fixing <- gsub("Enterovirus D68 strain ", "", fixing)
fixing <- gsub(", partial genome", "", fixing)
fixing <- gsub(", partial cds", "", fixing)
fixing <- gsub(", complete genome", "", fixing)
fixing <- gsub(", complete cds", "", fixing)
fixing <- gsub("polyprotein gene", "", fixing)
fixing <- gsub("Human enterovirus 68 isolate ", "", fixing)
fixing <- gsub("Human enterovirus 68 strain ", "", fixing)
fixing <- gsub("Enterovirus D68 genomic RNA, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 gene for polyprotein, strain: ", "", fixing)
fixing <- gsub("from France", "", fixing)
fixing <- gsub("From USA", "", fixing)
fixing <- gsub(" from USA", "", fixing)
fixing <- gsub(" from South Africa", "", fixing)
fixing <- gsub(" from Gambia", "", fixing)
fixing <- gsub(" from Senegal", "", fixing)
fixing <- gsub("UNVERIFIED: ", "", fixing)
fixing <- gsub(", partial sequence", "", fixing)
fixing <- gsub(", complete sequence", "", fixing)
fixing <- gsub(" polyprotein-like gene", "", fixing)
fixing <- gsub("Enterovirus D68 genomic RNA, nearly complete genome, strain: ", "", fixing)
fixing <- gsub("enterovirus D68 isolate EVCG618 genome assembly, chromosome: ", "", fixing)
fixing <- gsub(" genomic RNA$", "", fixing)
fixing <- gsub(" RNA$", "", fixing)
fixing <- gsub("Human enterovirus 68 VP1 gene for capsid protein VP1, Hospital study number: ", "", fixing)
fixing <- gsub("Human enterovirus 68 gene, 5'UTR, Hospital study number: ", "", fixing)
fixing <- gsub("Human enterovirus 68 gene for polyprotein, strain: ", "", fixing)
fixing <- gsub("Human enterovirus 68 VP1 gene for polyprotein, strain: ", "", fixing)
fixing <- gsub("Human enterovirus 68 gene for polyprotein, VP1 protein region, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 gene for polyprotein, VP1 protein region, strain: ", "", fixing)
fixing <- gsub(" VP1 protein gene", "", fixing)
fixing <- gsub("Human enterovirus 68, VP1, ", "", fixing)
fixing <- gsub(" 5' UTR", "", fixing)
fixing <- gsub(" VP1 gene", "", fixing)
fixing <- gsub(" , 5' UTR and partial cds", "", fixing)
fixing <- gsub(" VP2 gene", "", fixing)
fixing <- gsub("Human enterovirus 68 VP4/VP2 gene for VP4/VP2 polyprotein, note: ", "", fixing)
fixing <- gsub("Human enterovirus 68 gene, 5'UTR, note: Hospital study number: ", "", fixing)
fixing <- gsub(" capsid protein VP4/VP2 gene", "", fixing)
fixing <- gsub(" 3D RNA polymerase gene", "", fixing)
fixing <- gsub(" polyprotein VP4-VP2 region", "", fixing)
fixing <- gsub(" 5' untranslated region", "", fixing)
fixing <- gsub("Human rhinovirus 87 isolate ", "", fixing)
fixing <- gsub("Enterovirus D68 gene for polyprotein, VP4 protein region, strain: ", "", fixing)
fixing <- gsub(" VP4/VP2 protein gene", "", fixing)
fixing <- gsub(" , and partial cds", "", fixing)
fixing <- gsub("Human enterovirus 68 for capsid protein VP1, note: Hospital study number: ", "", fixing)
fixing <- gsub(" VP4VP2 gene", "", fixing)
fixing <- gsub(" capsid protein gene", "", fixing)
fixing <- gsub("Enterovirus D68 VP3 gene for VP3 polyprotein, isolate: ", "", fixing)
fixing <- gsub(" capsid protein", "", fixing)
fixing <- gsub("Enterovirus D68, isolate: ", "", fixing)
fixing <- gsub("Enterovirus D68 for VP2 polyprotein, isolate: ", "", fixing)
fixing <- gsub("Enterovirus D68 partial 1D gene for VP1 protein, isolate ", "", fixing)
fixing <- gsub(" viral protein 1 gene", "", fixing)
fixing <- gsub(" nonfunctional", "", fixing)
fixing <- gsub(" 1 gene", "", fixing)
fixing <- gsub(" VP4 gene", "", fixing)
fixing <- gsub(" gene for polyprotein", "", fixing)
fixing <- gsub(" polyprotein, VP1 region, gene", "", fixing)
fixing <- gsub(" polyprotein, VP1 protein region, gene", "", fixing)
fixing <- gsub(" for protein VP1", "", fixing)
fixing <- gsub(" polyprotein, VP4-VP2 region, gene", "", fixing)
fixing <- gsub("Enterovirus D68 gene for VP1 protein, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 partial 1D gene for VP1 protein, strain ", "", fixing)
fixing <- gsub(" polyprotein (POL) gene", "", fixing)
fixing <- gsub(" polyprotein (POL)", "", fixing)
fixing <- gsub("Enterovirus D68 for VP1 protein, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 partial 1D, VP1 protein region, complete 1D gene for VP1 protein, isolate ", "", fixing)
fixing <- gsub("Enterovirus D68 gene for VP4, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 for VP1, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 VP4/VP2, strain: ", "", fixing)
fixing <- gsub("Enterovirus D68 for VP1 polyprotein, isolate: ", "", fixing)
fixing <- gsub(" VP1 protein (VP1)", "", fixing)
fixing <- gsub(" VP1 (VP1)", "", fixing)
fixing <- gsub("Human rhinovirus 87 gene for VP4, strain:", "", fixing)
fixing <- gsub(" genomic RNA, 5'UTR", "", fixing)
fixing <- gsub("Enterovirus D68 complete 1D, VP1 region", "", fixing)
fixing <- gsub(", isolate ", "", fixing)
fixing <- gsub(" gene for", "", fixing)
fixing <- gsub(" VP1 protein (VP1)", "", fixing)
fixing <- gsub(" polyprotein (POL)", "", fixing)
#fixing <- gsub("xx", "", fixing)
#specifics
fixing <- gsub("Enterovirus D68 T", "T", fixing) #for those like this: Enterovirus D68 TTa-08-Ph561 RNA
fixing <- gsub("Enterovirus D68 take3", "take3", fixing)
fixing <- gsub("Enterovirus D68 take4", "take4", fixing)
fixing <- gsub("Enterovirus D68 take4", "take4", fixing)
#end of the line
fixing <- gsub(" 2C gene$", "", fixing)
fixing <- gsub(" gene$", "", fixing)
fixing <- gsub(" capsid$", "", fixing)
fixing <- gsub(" 2C gene$", "", fixing)
fixing <- gsub(" 2C protein$", "", fixing)
fixing <- gsub(" VP1$", "", fixing)
fixing <- gsub(" 3D$", "", fixing)
fixing <- gsub(" P1$", "", fixing)
fixing <- gsub(" P1 $", "", fixing)
fixing <- gsub(" VP4/2$", "", fixing)
fixing <- gsub(" and $", "", fixing)

#add something for empty strings
empties <- which(fixing == "")
fixing[empties] <- paste(rep("d68_seq", length(empties)), seq(1:length(empties)), sep="")

data_transformed[,"Strain Name"][[1]] <- fixing

#fix dates
datesFix <- data_transformed[,"Collection Date"][[1]]
#empty dates set properly
emptyDates <- grep("^$", datesFix)
datesFix[emptyDates] <- "20XX-XX-XX"
#only year
onlyYrLocations <- grep("[[:digit:]]{4}$", datesFix)
datesFix[onlyYrLocations] <- paste(datesFix[onlyYrLocations],"-XX-XX",sep="")
#month and year
mYrLocations <- grep("[[:digit:]]{4}-[[:digit:]]{2}$", datesFix)
datesFix[mYrLocations] <- paste(datesFix[mYrLocations],"-XX",sep="")

data_transformed[,"Collection Date"][[1]] <- datesFix

#there are two fermons, do I take care of this? no
#lets do it here
fermons <- which(data_transformed[,"Strain Name"] == "Fermon")
accs <- data_transformed[fermons,"GenBank Accession"]
new_names <- paste(rep("Fermon",length(fermons)), accs[[1]], sep="-")
data_transformed[fermons,"Strain Name"][[1]] <- new_names

# Write the transformed data to a TSV file
write.table(data_transformed, file = output, sep = "\t", row.names = FALSE, quote = FALSE)

