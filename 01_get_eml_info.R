library(xml2)
library(tidyverse)
path <- "../../../tmp/eml" #on datateam server; run Bryce's script to download all EML files from ADC
file_paths <- list.files(path, full.names = TRUE)

xml_raw <- tibble(file_paths = file_paths[!str_detect(file_paths, ".txt$")]) %>% 
  mutate(doc = map(file_paths, ~read_xml(.x)))

xml_proc <- xml_raw  %>% 
  mutate(funding = map_chr(doc, ~xml_find_all(.x, ".//funding") %>% paste(collapse = "; ")),
         pubDate = map_chr(doc, ~xml_find_all(.x, ".//pubDate") %>% paste(collapse = "; ")),
         file = str_extract(file_paths, "[^/]*$")) %>% 
  mutate(funding = str_extract_all(funding, "[A-z- ]*[0-9]{5,7}"),
         pubDate = str_extract_all(pubDate, "[0-9-]+")) %>% 
  select(-file_paths, -doc)

funding_clean <- xml_proc %>% 
  select(funding, file) %>% 
  unnest(funding) 

write_csv(funding_clean, "funding_clean.csv")

pubDate_clean <- xml_proc %>% 
  select(pubDate, file) %>% 
  unnest(pubDate) 

write_csv(pubDate_clean, "pubDate_clean.csv")