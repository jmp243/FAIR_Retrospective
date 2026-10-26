# Wichita State University
# 09-15-2026
# FAIR Retrospective
# Data Cleaning

# jungmee.park@wichita.edu

# load packages
library(openalexR)
library(tidyverse)
library(readr)

#### authoritative data source ####
# read in CSV of the works citing FAIR2016
citing_works <- read_csv("ten_yr_openalex_citation_corpus_2026-03-16.csv") # define to 3/15/2026

# rename display_name as title
citing_works$title <- citing_works$display_name

# remove http and other signifiers to make doi's compatible
citing_works <- citing_works %>% 
  mutate(doi_clean = str_remove(doi, "https://doi.org/"))

# remove rows without a doi
alex_doi <- citing_works %>% 
  filter(!is.na(doi) & doi != "") %>% 
  unique()

# filter out works that were published before 2015
# due to metadata errors in OpenAlex
alex_doi_new <- alex_doi %>%
  filter(publication_year > 2015)

#### Deduplication Steps ####
# create a dups dataframe for titles that appear more than once
dups <- alex_doi %>%
  group_by(title) %>%
  filter(n() > 1) %>%
  ungroup()

# keep the version that has at least one citation
dups_api <- alex_doi %>%
  group_by(title) %>%          
  filter(n() > 1) %>%          
  mutate(
    has_cites = any(cited_by_count > 0)                  
  ) %>%
  filter(has_cites) %>%       
  ungroup()

# remove has cites Binary variable that was created as a test
dups_api <- dups_api %>% 
  select(-has_cites)

# anti_join to take out the duplicates that are not cited
anti_dups <- anti_join(dups, dups_api)

# remove the anti_dups from the larger dataset alex_doi_new, matching by id
alex_doi_new <- alex_doi_new %>% anti_join(anti_dups, by = "id")

#### Merge in data from OpenAlex that includes Domain, Field, Subfields ####
# bring in new dataframe with the topics 
works_csv_August7_sourceID <- read_csv("works-csv-August7-sourceID.csv")

# rename column names
works_csv_August7_sourceID$doi <- works_csv_August7_sourceID$DOI

# remove duplicated columns
works_csv_August7 <- works_csv_August7_sourceID %>% 
  select(-c(Title, DOI, Year, `Citation count` )) 

# left_join this to the alex_doi_new
alex_doi_new1 <- alex_doi_new %>% 
  left_join(works_csv_August7, by = c("doi" = "doi"))

# find duplications in the new data frame
# keep the ones listed as primary accepted
dups_doi <- alex_doi_new1 %>%
  group_by(doi) %>%
  filter(n() > 1) %>% 
  filter(`Primary accepted` != "primary accepted") %>% 
  ungroup() # remove primary not accepted

# remove the unaccepted ones 
alex_doi_new1 <- alex_doi_new1 %>% anti_join(dups_doi, by = "doi")

# remove the originating article Wilkerson et al
alex_doi_new1 <-alex_doi_new1 %>% 
  filter(doi_clean != "10.1038/sdata.2016.18")

# unique row idenifier
alex_doi_new1 <- alex_doi_new1  %>%
  mutate(.row_id = row_number())

# save csv of new input data
write.csv(alex_doi_new1, file = "output_data/alex_doi_new1.csv")

#### Country Codes ####
# code modified from google ai search on July 1, 2026
# pivot the data frame longer
country_wide <- alex_doi_new1 %>%
  select(.row_id, authorships.countries) %>%
  # separate multiple rows
  separate_rows(authorships.countries, sep = "\\|") %>%
  mutate(
    country = str_trim(authorships.countries),
    country = toupper(country),         
    country = na_if(country, "")        # drop NA's
  ) %>%
  filter(!is.na(country)) %>%
  distinct(.row_id, country) %>%        
  mutate(has_country = 1L) %>%          
  pivot_wider(
    names_from = country,
    values_from = has_country,
    values_fill = 0
  )

library(countrycode)
# create a country code dictionary
country_codes <- names(country_wide)

# remove non‑country columns like ".row_id"
country_codes <- country_codes[country_codes != ".row_id"]

# create a country code dictionary using  ISO‑3166‑1 country code 
country_dict <- data.frame(
  code = country_codes,
  country = countrycode(country_codes, origin = "iso2c", destination = "country.name")
)

country_dict$country[country_dict$code == "XK"] <- "Kosovo" # add Kosovo

# Join back to original if you want the rest of the columns:
alex_doi_new_wide <- alex_doi_new1 %>%
  left_join(country_wide, by = ".row_id") %>%
  select(-.row_id)

# write to csv
write.csv(alex_doi_new_wide, file = "output_data/alex_doi_new_wide.csv")




