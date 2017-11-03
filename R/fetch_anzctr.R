library(xml2)
library(lubridate)


anzctr_xml_to_df <- function(filename) {
  doc <- read_xml(filename)
  df <- data.frame(
    actrnumber = doc %>% xml_find_all("/actrnumber") %>% xml_text(),
    #submit_date = doc %>% xml_find_all("submitdate") %>% xml_text() %>% as_date(),
    #approval_date = doc %>% xml_find_all("approvaldate") %>% xml_text() %>% as_date(),
    stage = doc %>% xml_find_all("/stage") %>% xml_text(),
    # utrn = doc %>% xml_find_all("//trial_identification/utrn") %>% xml_text(),
    study_title = doc %>% xml_find_all("//trial_identification/studytitle") %>% xml_text(),
    # scientific_title = doc %>% xml_find_all("//trial_identification/scientifictitle") %>% xml_text(),
    #trial_acronym = doc %>% xml_find_all("//trial_identification/trial_acronym") %>% xml_text(),
    # secondary_id = doc %>% xml_find_all("//trial_identification/secondaryid") %>% xml_text()
    
  )
  
  
  return(df)  
}

filename <- "./playground/anzctr_xml/ACTRN12617000596303.xml"
anzctr_xml_to_df(filename)
