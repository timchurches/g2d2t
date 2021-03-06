# needs patched version of rvest:
# devtools::install_github("timchurches/rvest")
# patched version of httr
# devtools::install_github("timchurches/httr")

library(httr)
library(rvest)

fetch_anzctr_xml_zip_file <- function(outfile, progress_obj) {
  # Initialise website session.
  anzctr_url <- "http://www.anzctr.org.au/TrialSearch.aspx?searchTxt=&isBasic=True"
  anzctr_session <- html_session(anzctr_url)
  # Get the form containing the download button in current session.
  download_form <- html_form(read_html(anzctr_session))[[1]]
  # fetch the data
  rc <- submit_form(session = anzctr_session,
        form = download_form,
        submit = "ctl00$body$btnDownload",
        httr::write_disk(outfile, overwrite = TRUE), httr::shiny_progress(shiny_progress_obj=progress_obj))
  # return(httr::status_code(rc))
  return(rc)
}

get_anzctr_download_status <- function(dbcon) { 
  status_text <- ""
  status_text <- try(as.character(as.tibble(dbReadTable(dbcon, "anzctr_download_status"))[1,"status"]))
  return(status_text)
}

# fetch the current number of ANZCTR trials
get_current_number_anzctr_trials <- function() {
  a <- list()
  a[[1]] <- c(NA, NA)
  try({a <- read_html("http://www.anzctr.org.au/TrialSearch.aspx?searchTxt=&isBasic=True") %>% html_nodes(xpath = '//*[@id="ctl00_body_resultCountLbl"]') %>% html_text() %>% strsplit(":")}, silent=TRUE)
  as.numeric(a[[1]][2])
}

# get_current_number_anzctr_trials()
