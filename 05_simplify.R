#in NSF true/false
#funding text
#funding number

funding_summary_full <- read_csv("funding_summary_full.csv")

funding_summary_simple <- funding_summary_full %>% 
  mutate(nsf_match = !is.na(title)) %>% 
  select(funding_num, funding_text, n_datasets, nsf_match, min_pubDate)

write_csv(funding_summary_simple, "funding_summary_simple.csv")
