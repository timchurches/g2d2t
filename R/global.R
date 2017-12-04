trainer_filename <- "/Users/tim.churches/g2d2t_data/trainer_progress.txt"
recogniser_filename <- "/Users/tim.churches/g2d2t_data/recogniser_progress.txt"
nlp_status_file <- "/Users/tim.churches/g2d2t_data/nlp_status.txt"
nlp_feather_file <- "/Users/tim.churches/g2d2t_data/recognised_drug_names.feather"
interventions_feather_file <- "/Users/tim.churches/g2d2t_data/interventions.feather"
drug_names_feather_file <- "/Users/tim.churches/g2d2t_data/drug_names.feather"
# anzctr_download_shell_file <- "/Users/tim.churches/g2d2t/R/fetch_all_anzctr2.sh"
anzctr_download_file <- "/Users/tim.churches/g2d2t_data/anzctr_xml.zip"
dbdir <- "/Users/tim.churches/g2d2t_data/MonetDBLite"
anzctr_xmlpath <- "/Users/tim.churches/g2d2t_data/anzctr_xml"

# database connection
dbcon <- DBI::dbConnect(MonetDBLite::MonetDBLite(), dbdir)

# pager code
source('pagerui.R')
# code for fetching ANZCTR XML files
source("httr_fetch_anzctr.R")
# code for loading the ANZCTR XML files
source("read_anzctr_xml_funcs.R")
# code for fetch and loading the DrugBank files
source("fetch_DrugData.R")
source("passwords.R")

# utilities
source("utils.R")
