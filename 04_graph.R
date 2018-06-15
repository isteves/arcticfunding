library(tidyverse)
library(lubridate)

funding_summary <- read_csv("funding_summary.csv")
funding_clean <- read_csv("funding_clean.csv")
pubDate_clean <- read_csv("pubDate_clean.csv")

fund_pubDate <- funding_clean %>% 
  na.omit() %>% 
  left_join(pubDate_clean, by = "file") %>% 
  mutate(funding_num = str_extract(funding, "[0-9]{5,7}"),
         pubDate = parse_date_time(pubDate,
                                   c('%Y','%Y-%m-%d'), exact = TRUE)) %>% 
  group_by(funding_num) %>% 
  summarize(min_pubDate = min(pubDate))

funding_summary_full <- funding_summary %>% 
  left_join(fund_pubDate, by = "funding_num") 

write_csv(funding_summary_full, "funding_summary_full.csv")

cplot <- funding_summary_full %>% 
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
