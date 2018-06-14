# Aims: -----------
# 1) a table of the number of data sets in the Arctic Data Center (only count one version for each data set) for each NSF award number?  
# Then, produce 2) a graph showing number of NSF awards represented in the ADC over time?

# Set-up ---------
library(dataone)
library(tidyverse)
library(lubridate)
library(httr)

cn <- dataone::CNode("PROD")
mn <- dataone::getMNode(cn, "urn:node:ARCTIC")

# Get all current Arctic Data Center metadata ---------
adc_metadata <- query(mn, list(q = "-obsoletedBy:* AND formatType:METADATA",
                    fl = "id, text, datePublished",
                    rows = "5120"),
           as = "data.frame")
#if query doesn't work, try rerunning a few times with different numbers of rows
#related error message: Error: 1: internal error: Huge input lookup

# if desired, save to csv
# write.csv(adc_metadata, "adc_metadata.csv", row.names = FALSE)
# adc_metadata <- read_csv("adc_metadata.csv")

# TRIED: Extract possible funding numbers from text field ---------
# funding <- adc_metadata %>% 
#   as.tibble() %>% 
#   mutate(num_text = str_extract_all(text, ".{10}[0-9]{5,7} .{10}")) %>% 
#   unnest()
# 
# x <- funding %>% 
#   select(num_text) %>% 
#   filter(
#     !str_detect(num_text, "Box|USA"), #po boxes, addresses with USA
#     !str_detect(num_text, "[.][0-9]{5,7}"), #geo cov
#     !str_detect(num_text, " [a-zA-Z]{2}[ ]+[0-9]{5,7}"), #abbreviated states
#     !str_detect(num_text, "[uuid].*[0-9]{5,7}"), #urn
#     !str_detect(num_text, "[A-z0-9][.][a-zA-Z]{2,4}[ ]+[0-9]{5,7}") #file bytes
#   )
#CONCLUSION: ran into too many problems with numbers in text: urn's, zip codes, (foreign) phone #'s, bytes, geo cov, etc.

# TRIED filtering out awards that are NSF polar-related -------
      # 
      # # Get NSF award numbers
      # polar_awards <- datamgmt::get_awards(print_fields = "id") #saved as polar-awards.csv
      # polar_awards_c <- paste(polar_awards, collapse = " ")
      # 
      # # Match to current polar NSF list (17824 --> 1405)
      # funding_filtered <- funding %>% 
      #   mutate(polar = map_lgl(funding, ~str_detect(polar_awards_c, .x))) %>% 
      #   filter(polar)
      #
# CONCLUSION: not great -- some polar awards slipped through the cracks

# Check funding numbers against the NSF API ----------
check_nsf <- function(award) {
  url <- paste0("http://api.nsf.gov/services/v1/awards/", award, ".json")
  req <- httr::GET(url)
  flat <- content(req)$response$award %>% flatten()
  
  if(length(flat) == 0){
    return(NA)
  } else {
    return(flat$title)
  }
}

#NOTE: this takes a long time to run!
nsf_matching <- funding %>% 
  select(funding) %>% 
  distinct() %>% 
  mutate(title = map_chr(funding, check_nsf)) 

# results saved as:
# write.csv(nsf_matching, "nsf_matching.csv", row.names = FALSE)
# nsf_matching <- read_csv("nsf_matching.csv")

# Join with funding and filter out NA's --------
funding_nsf <- funding %>% 
  left_join(nsf_matching, by = "funding") %>% 
  filter(title != "NA") #might need to change if saved as NA instead of "NA"

# Aim 1: Funding summary (table with funding numbers & number datasets)
funding_summary <- funding_nsf %>% 
  select(id, funding) %>% 
  group_by(funding) %>% 
  summarize(n_datasets = n())

write.csv(funding_summary, "funding_summary.csv", row.names = FALSE)

# Aim 2: graph cumulative datasets
# Get earliest publish date
funding_dates <- funding_nsf %>% 
  mutate(datePublished = ymd_hms(datePublished)) %>% 
  group_by(funding) %>% 
  summarize(date = min(datePublished)) %>% 
  arrange(date) %>%
  mutate(count = 1,
         ccount = cumsum(count))

cplot <- ggplot(funding_dates, aes(x = date, y = ccount)) +
  geom_line() +
  xlab("Date") + ylab("Cumulative datasets") +
  theme_bw()
#auto-removed files without dates

ggsave("awards_over_time.png")
