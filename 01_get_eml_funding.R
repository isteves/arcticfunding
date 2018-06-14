#use files downloaded by Bryce:

library(xml2)
library(tidyverse)
path <- "../../../tmp/eml" #on datateam server
file_paths <- list.files(path, full.names = TRUE)

funding_raw <- tibble(file_paths = file_paths[!str_detect(file_paths, ".txt$")]) %>% 
  mutate(funding = map(file_paths, ~.x %>% 
                             read_xml() %>% 
                             xml_find_all(".//funding") %>% 
                             as.character()),
         funding = as.character(funding))

funding_clean <- funding_raw %>% 
  mutate(file = str_extract(file_paths, "[^/]*$"),
         funding = str_extract(funding, "[A-z- ]*[0-9]{5,7}")) %>% 
  select(-file_paths)

write_csv(funding_clean, "funding_clean.csv")
