source("census-key.R")
url <- "https://api.census.gov/data/2021/pep/population"
library(httr2)
request <- request(url) |> 
  req_url_query(get = "POP_2020,POP_2021,NAME",
                'for' = "state:*",
                key = census_key)
response <- req_perform(request)
#population created
population <- resp_body_json(response,simplifyVector = TRUE) |> as.matrix()

url <- "https://github.com/datasciencelabs/2024/raw/refs/heads/main/data/regions.json"
library(jsonlite)
library(purrr)
library(tidyverse)
library(janitor)
population <- population |> row_to_names(1) |> 
  as_tibble() |> 
  select(-state) |> 
  rename(state_name = NAME) |> 
  pivot_longer(cols = c("POP_2020", "POP_2021") ,names_to = "year", values_to = "population") |> 
  mutate(year = str_remove(year, "POP_") |> as.numeric(),
         population = as.numeric(population),
         state = case_when(
           state_name == "District of Columbia" ~ "DC",
           state_name == "Puerto Rico" ~ "PR",
           TRUE ~ state.abb[match(state_name, state.name)]
         ))
#read in regions
url <- "https://github.com/datasciencelabs/2024/raw/refs/heads/main/data/regions.json"
regions <- fromJSON(url) |> 
  mutate(region_name = ifelse(region_name == "New York and New Jersey, Puerto Rico, Virgin Islands", "NY&NJ, PR, Virgin Islands", region_name)) |>
  unnest(states) |>
  rename(state_name = states) |>
  mutate(region = as.character(region)) |> 
  mutate(region = factor(region))
#combine regions and population
population <- population |> left_join(regions, by = "state_name")