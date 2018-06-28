# Match funding numbers to NSF API
library(httr)
library(tidyverse)

eml_info <- read_csv("eml_info.csv")

match_nsf <- function(award) {
  url <- paste0("http://api.nsf.gov/services/v1/awards/", award, 
                ".json?printFields=fundProgramName,title,date,startDate,expDate")
  req <- httr::GET(url)
  flat <- httr::content(req)$response$award %>% unlist()
  
  return(flat)
}

#takes a while due to api calls
nsf_matching <- eml_info %>% 
  select(funding_num) %>% 
  distinct() %>% 
  mutate(info = map(funding_num, match_nsf)) 

# clean up matched results
nsf_matches <- nsf_matching %>% 
  filter(info %in% compact(info)) %>% 
  mutate(info_names = map(info, names)) %>% 
  unnest() %>% 
  spread(info_names, info)
  
write_csv(nsf_matches, "nsf_matches.csv")
