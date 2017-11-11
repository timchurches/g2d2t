library(tidytext)

delim_pattern <- "\\s+|[,!?\\.:;]\\s+"

anzctr_core %>% select(trial_number, interventions) %>% unnest_tokens(word, interventions, token='regex', pattern=delim_pattern) %>% group_by(word) %>% count() %>% arrange(desc(n)) -> a

anzctr_health_conditions  %>% unnest_tokens(word, health_condition, token='regex', pattern=delim_pattern) %>% group_by(word) %>% count() %>% arrange(desc(n)) -> b
