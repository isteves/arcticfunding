# Graph results using pubDate instead of dateUploaded field

dateUploaded <- read_delim("/home/mecum/latest-eml.txt", delim = " ") %>% 
  rename(file = filename)
eml_info <- read_csv("eml_info.csv")
funding_summary <- read_csv("funding_summary.csv")

fund_dateUploaded <- eml_info %>% 
  na.omit() %>% 
  left_join(dateUploaded, by = "file") %>% 
  group_by(funding_num) %>% 
  summarize(min_dateUploaded = min(date_uploaded)) %>% 
  inner_join(funding_summary, by = "funding_num")

cplot <- fund_dateUploaded %>% 
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
