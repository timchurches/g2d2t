########################################
## Import of DrugBank Annotation Data ##
########################################
## Function to import DrugBank xml to data.frame and store in SQLite database.
## Note, this functions needs some major speed improvements. Ideally,
## (1) Download
##     - download DrugBank xml file (https://www.drugbank.ca/releases/latest)
##     - name uncompressed file 'drugbank.xml'
## (2) Function to convert xml into dataframe and store in SQLite database.

#' @export
#' @importFrom XML xmlParse
#' @importFrom XML xmlRoot
#' @importFrom XML xmlSize
#' @importFrom XML xmlToDataFrame

library(tidyverse)

source("R/passwords.R")

get_drugbank <- function(types, username="", password="", version="5-0-9") {
  everything <- c("all-drug-links", "target-all-uniprot-links",
                  "enzyme-all-uniprot-links", "carrier-all-uniprot-links",
                  "transporter-all-uniprot-links", "all-structures", 
                  "target-all-polypeptide-ids", "enzyme-all-polypeptide-ids",
                  "carrier-all-polypeptide-ids", "transporter-all-polypeptide-ids",
                  "target-all-polypeptide-sequences", "enzyme-all-polypeptide-sequences",
                  "carrier-all-polypeptide-sequences", "transporter-all-polypeptide-sequences",
                  "all-drug-sequences", "all-drugbank-vocabulary", "all-open-structures")
  types <- stringr::str_to_lower(types)
  if (types == "everything") types <- everything
  if (!all(types %in% everything)) {
    stop("incorrect or null types specified, use 'everything' to fetch all data types")
  }
  fetched_files <- c()
  rcs <- c()
  tmpdir = gsub("//","/", tempdir())
  for (t in types) {
    fileext <- ".csv.zip"
    if (stringr::str_detect(t, "sequences")) fileext <- ".fasta.zip"
    if (stringr::str_detect(t, "structures")) fileext <- ".sdf.zip"
    tmp <- tempfile(pattern=paste("drugbank", version, t, sep="-",col=""), 
                    tmpdir = gsub("//","/", tempdir()), fileext = fileext)
    rc <- system2("curl", args=c("-Lf", "-o", tmp, "-u", paste(username, ":", password, sep="", collapse=NULL), paste("https://www.drugbank.ca/releases/", version, "/downloads/", t, sep="")))
    # try again once if non-zero rc
    if (rc) {
      rc <- system2("curl", args=c("-Lf", "-o", tmp, "-u", paste(username, ":", password, sep="", collapse=NULL), paste("https://www.drugbank.ca/releases/", version, "/downloads/", t, sep="")))
    }
    rcs <- c(rcs, rc)
    fetched_files <- c(fetched_files, tmp)
  }  
  return(list(types=types, rcs=rcs, fetched_files=fetched_files))
}

drugbank_fetches <- get_drugbank("everything", username=drugbank_username, password=drugbank_password)

read_drugbank <- function(filename) {
    split_fname <- unlist(strsplit(filename, "[.]"))
    type <- split_fname[length(split_fname) - 1]
    if (type == "csv") {
      df <- read_csv(filename) 
    } else {
      df <- NULL
    }
    return(list(type=type, df=df))
}

length(a[["types"]])
any(a[["rcs"]])
a[["fetched_files"]]

for (db in drugbank_fetches) {
  b <- read_drugbank("/var/folders/38/7hkr3gf548s5lt7mmd7058_m0000gp/T/RtmpFVIHFh/drugbank-5-0-9-all-drug-links-34e7722bc583.csv.zip")
}
