source("R/read_anzctr_xml_funcs.R", echo = FALSE)
dbdir <- "/Users/tim.churches/g2d2t/data/MonetDBLite"
con <- dbConnect(MonetDBLite::MonetDBLite(), dbdir)
ingest_anzctr_xml(xmlpath="/Users/tim.churches/g2d2t/data/anzctr_xml", dbcon=con, progress_obj=NULL)
