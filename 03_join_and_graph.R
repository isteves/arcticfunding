# Combine data and graph over time

library(tidyverse)
library(lubridate)

nsf_matches <- read_csv("nsf_matches.csv")
eml_info <- read_csv("eml_info.csv")
dateUploaded <- read_delim("/home/mecum/latest-eml.txt", delim = " ") %>% 
  rename(file = filename)

# Join eml_info to nsf api output
funding_summary <- eml_info %>% 
  left_join(dateUploaded, by = "file") %>% 
  mutate(pubDate = parse_date_time(pubDate,
                                   c('%Y','%Y-%m-%d'), exact = TRUE)) %>% 
  group_by(funding_num) %>% 
  summarize(n_datasets = n(),
            dataset_ids = paste(file, collapse = "; "),
            funding_text = paste(unique(funding), collapse = "; "),
            min_pubDate = min(pubDate),
            min_dateUploaded = min(date_uploaded)) %>% 
  inner_join(nsf_matches, by = "funding_num") 
  
write_csv(funding_summary, "funding_summary.csv")

# Graph over time
cplot <- funding_summary %>% 
  filter(!is.na(title), !is.na(min_pubDate)) %>% 
  arrange(min_pubDate) %>%
  mutate(count = 1,
         ccount = cumsum(count)) %>% 
  ggplot(aes(x = min_pubDate, y = ccount)) +
  geom_line() +
  xlab("Date") + ylab("Cumulative datasets") +
  theme_bw()
#auto-removed files without dates

ggsave("images/awards_over_time.png")

cplot2 <- funding_summary %>% 
  filter(!is.na(title), !is.na(min_dateUploaded)) %>% 
  arrange(min_dateUploaded) %>%
  mutate(count = 1,
         ccount = cumsum(count)) %>% 
  ggplot(aes(x = min_dateUploaded, y = ccount)) +
  geom_line() +
  xlab("Date") + ylab("Cumulative datasets") +
  theme_bw()
#auto-removed files without dates

ggsave("images/awards_dateUploaded.png")

funding_summary_simple <- funding_summary %>% 
  mutate(nsf_match = !is.na(title)) %>% 
  select(funding_num, funding_text, n_datasets, nsf_match, min_pubDate, min_dateUploaded)

write_csv(funding_summary_simple, "funding_summary_simple.csv")
