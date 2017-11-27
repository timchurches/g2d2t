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
library(DBI)
library(rvest)

stopifnot("MonetDBLite" %in% rownames(installed.packages()))

# fetch the details of DrugBank releases
drugbank_releases_df <- read_html("https://www.drugbank.ca/releases") %>% html_nodes("table") %>% html_table() %>% .[[1]] %>% rename(version=Version, release_date="Released on", total_files="Total files", total_size="Total size") %>% select(version, release_date, total_files, total_size) %>% mutate(release_date=as.Date(release_date),  version=gsub("\\.","-",version)) %>% arrange(desc(release_date))

# get the latest release
latest_drugbank_release <- drugbank_releases_df[1,"version"]

get_drugbank <- function(types, username="", password="", version=latest_drugbank_release, progress_obj=NULL) {
  everything <- c("all-drug-links", "target-all-uniprot-links",
                  "enzyme-all-uniprot-links", "carrier-all-uniprot-links",
                  "transporter-all-uniprot-links", "all-structures", "all-structure-links",
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
  fetch_counter <- 0
  for (t in types) {
    fetch_counter <- fetch_counter + 1
    if (!is.null(progress_obj)) {
      progress_obj$set(value=(fetch_counter/length(types))*10000, message=paste("Downloading DrugBank.ca file", fetch_counter, "of", length(types)))
    }
    fileext <- ".csv.zip"
    if (stringr::str_detect(t, "sequences")) fileext <- ".fasta.zip"
    if (stringr::str_detect(t, "structures")) fileext <- ".sdf.zip"
    tmp <- tempfile(pattern=paste("drugbank", version, t, sep="-",col=""), 
                    tmpdir = gsub("//","/", tempdir()), fileext = fileext)
    furl <- paste("https://www.drugbank.ca/releases/", version, "/downloads/", t, sep="")
    rc <- system2("curl", args=c("-Lf", "-o", tmp, "-u", paste(username, ":", password, sep="", collapse=NULL), furl))
    # try again once if non-zero rc
    if (rc) {
      rc <- system2("curl", args=c("-Lf", "-o", tmp, "-u", paste(username, ":", password, sep="", collapse=NULL), furl))
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
  for (x in seq_along(drugbank_fetch_list[["types"]])) {
    ftype <- drugbank_fetch_list[["types"]][x]
    fname <- drugbank_fetch_list[["fetched_files"]][x]
    df <- read_drugbank(fname)
    # print(df)
    if (df[["type"]] == "csv") { 
      assign(paste("drugbank_", gsub("-","_", ftype), sep=""), df[["df"]], envir = .GlobalEnv)
    }
  }
}

# fix up aspects of the drugbank data, create some extra tables
wrangle_drugbank_data <- function() {
    # ugly renaming of columns with spaces in them - rename() in dplyr doesn't seem to work?
    drugbank_target_all_polypeptide_ids$drug_ids <<- drugbank_target_all_polypeptide_ids$"Drug IDs"
    drugbank_target_all_polypeptide_ids$name <<- drugbank_target_all_polypeptide_ids$"Name"
    drugbank_target_all_polypeptide_ids$gene_name <<- drugbank_target_all_polypeptide_ids$"Gene Name"
    
    drops <- c("Drug IDs","Name", "Gene Name")
    drugbank_target_all_polypeptide_ids <<- drugbank_target_all_polypeptide_ids[ , !(names(drugbank_target_all_polypeptide_ids) %in% drops)]
    
    gene2drug_id <<- drugbank_target_all_polypeptide_ids %>% select(ID, name, gene_name, drug_ids) %>% separate_rows(drug_ids, convert=TRUE) %>% rename(drug_id=drug_ids) 
    
    gene_common_names <<- gene2drug_id %>% rename(term=name) %>% distinct(ID, drug_id, term) %>% mutate(type="gene_common_name") 
    
    gene_symbols <<- gene2drug_id %>% rename(term=gene_name) %>% distinct(ID, drug_id, term) %>% mutate(type="gene_symbol")
    
    gene_terms2drug_id <<- bind_rows(gene_common_names, gene_symbols) %>% arrange(ID, drug_id)
    
    drugbank_all_drugbank_vocabulary$drug_id <<- drugbank_all_drugbank_vocabulary$"DrugBank ID"
    drugbank_all_drugbank_vocabulary$common_name <<- drugbank_all_drugbank_vocabulary$"Common name"
    drugbank_all_drugbank_vocabulary$synonyms <<- drugbank_all_drugbank_vocabulary$"Synonyms"
    
    drops <- c("DrugBank ID","Common name", "Synonyms")
    drugbank_all_drugbank_vocabulary <<- drugbank_all_drugbank_vocabulary[ , !(names(drugbank_all_drugbank_vocabulary) %in% drops)]
    
    drug_name2drug_id <<- drugbank_all_drugbank_vocabulary %>% select(drug_id, common_name, synonyms) %>% separate_rows(synonyms, sep=" \\| ", convert=TRUE)
    
    drug_common_names <<- drug_name2drug_id %>% rename(term=common_name) %>% distinct(drug_id, term) %>% mutate(type="drug_common_name") 
    
    drug_synonyms <<- drug_name2drug_id %>% rename(term=synonyms) %>% distinct(drug_id, term) %>% mutate(type="drug_synonym")  
    
    drug_terms2drug_id <<- bind_rows(drug_common_names, drug_synonyms) %>% arrange(drug_id)
    
    drugs2drug_id2genes <<- drug_terms2drug_id %>% rename(drug_term=term, drug_term_type=type) %>% inner_join(gene_terms2drug_id %>% rename(gene_term=term, gene_term_type=type), by="drug_id") 
}

# drugbank_fetches <- get_drugbank("everything", username=drugbank_username, password=drugbank_password, progress_obj=NULL)

# create_drugbank_data_frames(drugbank_fetches)

# wrangle_drugbank_data()

#     
# Used in HealthHack 2017
# drug_terms2drug_id %>% rename(associated_id=drug_id) %>% select(associated_id, term, type) %>% distinct(associated_id, term, type) %>% write_csv("data/drug_terms.csv")

# gene_terms2drug_id %>% rename(associated_id=ID) %>% filter(term != "NA", !term %in% 0:99, !term %in% LETTERS, !term %in% letters) %>% select(associated_id, term, type) %>% distinct(associated_id, term, type) %>% write_csv("data/gene_terms.csv")

# Write to a database
store_drugbank_df <- function(df_name, dbcon) {
  # load into database
  dbWriteTable(dbcon, df_name, get(df_name), overwrite=TRUE)
  message(paste("Loaded", df_name, "tbl containing", nrow(get(df_name)), "rows into MonetDB database."))
  invisible(NULL)
}

drugbank_df_names <- c(
"drug_common_names",
"drug_name2drug_id",
"drug_synonyms",
"drug_terms2drug_id",
"drugbank_all_drug_links",
"drugbank_all_drugbank_vocabulary",
"drugbank_carrier_all_polypeptide_ids",
"drugbank_carrier_all_uniprot_links",
"drugbank_enzyme_all_polypeptide_ids",
"drugbank_enzyme_all_uniprot_links",
"drugbank_target_all_polypeptide_ids",
"drugbank_target_all_uniprot_links",
"drugbank_transporter_all_polypeptide_ids",
"drugbank_transporter_all_uniprot_links",
"drugs2drug_id2genes",
"gene_common_names",
"gene_symbols",
"gene_terms2drug_id",
"gene2drug_id")

store_drugbank_dfs <- function(df_names=drugbank_df_names, dbcon) {
  for (df_name in df_names) {
    store_drugbank_df(df_name, dbcon)
  }
}

assign_drugbank_df <- function(df_name,envir, dbcon) {
  # assign to the calling environment
  df <- as.tibble(dbReadTable(dbcon, df_name))
  assign(df_name, df, envir=envir)
  message(paste("Loaded", df_name, "tbl containing", nrow(df), "rows."))
  invisible(NULL)
}

load_drugbank_dfs <- function(df_names, dbcon) {
  for (df_name in df_names) {
    assign_drugbank_df(df_name, parent.frame(), dbcon)
  }
}

# load_drugbank_dfs(dbcon=dbcon) 
