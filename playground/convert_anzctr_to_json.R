# convert ANZCTR records, stored in individual XML files to single JSON list.
library(tidyverse)
source("R/fetch_anzctr.R")
# head(anzctr)
library(jsonlite)
write_json(anzctr, "anzctr.json")
