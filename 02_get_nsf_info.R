# Match funding numbers to NSF API
library(httr)
library(tidyverse)

funding_clean <- read_csv("funding_clean.csv")

match_nsf <- function(award) {
  url <- paste0("http://api.nsf.gov/services/v1/awards/", award, 
                ".json?printFields=fundProgramName,title,date,startDate,expDate")
  req <- httr::GET(url)
  flat <- httr::content(req)$response$award %>% unlist()
  
  return(flat)
}

#takes a while due to api calls
nsf_matching <- funding_clean %>% 
  mutate(funding_num = str_extract(funding, "[0-9]{5,7}")) %>% 
  nest(-funding_num) %>% 
  mutate(info = map(funding_num, match_nsf)) 

nsf_matching_clean <- nsf_matching %>% 
  filter(info %in% compact(info)) %>% 
  mutate(info_names = map(info, names)) %>% 
  unnest() %>% 
  spread(info_names, info)
  
write_csv(nsf_matching_clean, "nsf_matches.csv")

funding_summary <- funding_clean %>% 
  mutate(funding_num = str_extract(funding, "[0-9]{5,7}")) %>% 
  group_by(funding_num) %>% 
  summarize(n_datasets = n(),
            dataset_ids = paste(file, collapse = "; "),
            funding_text = paste(unique(funding), collapse = "; "))
  
write_csv(funding_summary, "funding_summary.csv")
