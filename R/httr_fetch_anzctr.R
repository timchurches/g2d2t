# needs patched version of rvest:
# devtools::install_github("timchurches/rvest")

library(rvest)

fetch_anzctr_xml_zip_file <- function(outfile) {
  # Initialise website session.
  anzctr_url <- "http://www.anzctr.org.au/TrialSearch.aspx?searchTxt=&isBasic=True"
  anzctr_session <- html_session(anzctr_url)
  # Get forms with searchable fields in current session.
  download_form <- html_form(read_html(anzctr_session))[[1]]
  # fetch the data
  rc <- submit_form(session = anzctr_session,
        form = download_form,
        submit = "ctl00$body$btnDownload",
        httr::write_disk(outfile, overwrite = TRUE))
  return(httr::status_code(rc))
}




