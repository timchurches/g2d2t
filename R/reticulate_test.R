library(reticulate)
feather <- import("feather")

py <- import_builtins()
yr <- py_run_file("src/yrange.py")

yr$fibnum <- 7

yr$fibnum

a <- yr$Fib(yr$fibnum)

iterate(a)


a <- py_capture_output(sp$main(), type = c("stdout", "stderr"))


num_drugs <- sp$drugbank_matcher$num_drugs

drugbank_matcher <- sp$DrugBankMatcher(nlp=sp$nlp, drugs=sp$drug_names_list)  

pb <- progress_bar$new(
      format = paste("Training matcher with drug name :current of :total (:percent), estimated completion in :eta"),
      total = num_drugs, clear = FALSE, width= 60)

for (n in 1:num_drugs) {
  a <- iter_next(drugbank_matcher)
  pb$tick()
}

num_texts <- sp$drugbank_recogniser$num_texts

print(num_texts)

pb <- progress_bar$new(
      format = paste("Matching drugs in text :current of :total (:percent), estimated completion in :eta"),
      total = num_texts, clear = FALSE, width= 60)

for (n in 1:num_texts) {
  a <- iter_next(sp$drugbank_recogniser)
  pb$tick()
}
