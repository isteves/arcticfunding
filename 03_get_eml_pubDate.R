#use new files with to get dateUploaded field

library(xml2)
library(tidyverse)
path <- "../../../tmp/eml" #on datateam server
file_paths <- list.files(path, full.names = TRUE)

pubDate_raw <- tibble(file_paths = file_paths[!str_detect(file_paths, ".txt$")]) %>% 
  mutate(pubDate = map(file_paths, ~.x %>% 
                         read_xml() %>% 
                         xml_find_all(".//pubDate") %>% 
                         as.character()))

pubDate_clean <- pubDate_raw %>% 
  mutate(file = str_extract(file_paths, "[^/]*$"),
         pubDate = map(pubDate, ~str_extract(.x, "[0-9-]+"))) %>% 
  unnest(pubDate) %>% 
  select(-file_paths)

write_csv(pubDate_clean, "pubDate_clean.csv")