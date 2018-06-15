# Check graph results using pubDate against dateUploaded field

dateUploaded <- read_delim("/home/mecum/latest-eml.txt", delim = " ") %>% 
  rename(file = filename)
funding_clean <- read_csv("funding_clean.csv")

fund_dateUploaded <- funding_clean %>% 
  na.omit() %>% 
  left_join(dateUploaded, by = "file") %>% 
  mutate(funding_num = str_extract(funding, "[0-9]{5,7}")) %>% 
  group_by(funding_num) %>% 
  summarize(min_dateUploaded = min(date_uploaded))

funding_summary_full <- read_csv("funding_summary_full.csv")

funding_summary_full2 <- funding_summary_full %>% 
  left_join(fund_dateUploaded, by = "funding_num") 

cplot <- funding_summary_full2 %>% 
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
