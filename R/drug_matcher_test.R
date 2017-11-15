library(feather)

source("R/load_anzctr_dfs.R", echo=FALSE)

interventions_df <- anzctr_core[,c("trial_number", "interventions")]
path <- "data/interventions.feather"
write_feather(interventions_df, path)

path <- "data/drug_names.feather"
write_feather(drug_terms2drug_id, path)

system("python src/matcher_test2.py")
