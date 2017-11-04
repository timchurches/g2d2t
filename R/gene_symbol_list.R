library(org.Hs.eg.db) 

uniKeys <- keys(org.Hs.eg.db, keytype="ENTREZID")
cols <- c("SYMBOL")
a <- select(org.Hs.eg.db, keys=uniKeys, columns=cols, keytype="ENTREZID")
a$term <- a$SYMBOL
a$associated_id <- a$ENTREZID
a %>% dplyr::select(associated_id, term) %>% mutate(type="ENTREZID") %>% write_csv("data/entrezid_terms.csv")
