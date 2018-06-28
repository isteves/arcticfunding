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
  select(-pubDate) %>% 
  unnest(funding) %>% 
  mutate(funding_num = str_extract(funding, "[0-9]{5,7}")) 

pubDate_clean <- xml_proc %>% 
  select(-funding) %>% 
  unnest(pubDate) 

# Join funding and pubDate back together
eml_info <- funding_clean %>% 
  left_join(pubDate_clean, by = "file")

write_csv(eml_info, "eml_info.csv")
