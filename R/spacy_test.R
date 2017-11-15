library(spacyr)
spacy_initialize(model='en_core_web_lg',python_executable="/Users/tim.churches/anaconda/bin/python")

source("R/load_anzctr_dfs.R", echo=FALSE)

txt <- anzctr_core[1:10,]$interventions

txt


# process documents and obtain a data.table

parsedtxt <- spacy_parse(txt, tag = TRUE, entity = TRUE, lemma = FALSE, dependency=TRUE)
parsedtxt
