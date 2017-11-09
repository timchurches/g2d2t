library(tidyverse)
library(lubridate)
library(progress)
library(DBI)
source("R/read_anzctr_xml_funcs.R", echo = FALSE)

dbdir <- "playground/MonetDBLite"
con <- dbConnect(MonetDBLite::MonetDBLite(), dbdir)

load_anzctr_dfs(dbcon=con)
