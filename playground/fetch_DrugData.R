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

read_drugbank <- function(filename) {
    split_fname <- unlist(strsplit(filename, "[.]"))
    type <- split_fname[length(split_fname) - 1]
    if (type == "csv") {
      df <- read_csv(filename) 
    } else {
      df <- NULL
    }
    return(list(type=type,df=df))
}

create_drugbank_data_frames <- function(drugbank_fetch_list) {
  for (x in seq_along(drugbank_fetches[["types"]])) {
    ftype <- drugbank_fetches[["types"]][x]
    fname <- drugbank_fetches[["fetched_files"]][x]
    df <- read_drugbank(fname)
    # print(df)
    if (df[["type"]] == "csv") { 
      assign(paste("drugbank_", gsub("-","_", ftype), sep=""), df[["df"]], envir = .GlobalEnv)
    }
  }
}

drugbank_fetches <- get_drugbank("everything", username=drugbank_username, password=drugbank_password)

create_drugbank_data_frames(drugbank_fetches)

# ugly renaming of columns with spaces in them - rename() in dplyr doesn't seem to work?
drugbank_target_all_polypeptide_ids$drug_ids <- drugbank_target_all_polypeptide_ids[,"Drug IDs"]
drugbank_target_all_polypeptide_ids[,"Drug IDs"] <- NULL
drugbank_target_all_polypeptide_ids$name <- drugbank_target_all_polypeptide_ids[,"Name"]
drugbank_target_all_polypeptide_ids[,"Name"] <- NULL
drugbank_target_all_polypeptide_ids$gene_name <- drugbank_target_all_polypeptide_ids[,"Gene Name"]
drugbank_target_all_polypeptide_ids[,"Gene Name"] <- NULL

# library(dplyr)

# drugbank_target_all_polypeptide_ids %>% select(ID, name, gene_name, drug_ids) %>% separate_rows(drug_ids, convert=TRUE) -> gene2drug_id

