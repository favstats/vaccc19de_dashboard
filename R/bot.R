
library(tidyverse)
library(twitteR)

## source some utility functions
source("R/utils.R")

## read in data
rki_dat <- readRDS("data/rki_dat.RDS")

## we dont need German data
rki_dat <- rki_dat %>%
  filter(bundesland != "Deutschland")

## create the most recent data
latest_dat <- rki_dat %>%
  dplyr::filter(day==max(day))

## create the pre-recent data
prelatest_dat <- rki_dat %>%
  dplyr::filter(day<max(day)) %>%
  dplyr::filter(day==max(day))

## last and current update day
latest_day <- unique(prelatest_dat$day) %>% format.Date("%d.%m.%Y")
current_day <- unique(latest_dat$day) %>% format.Date("%d.%m.%Y")


## set up Twitter
name <- "MyTotallyAwesomeUniqueApp"

consumer_key <- Sys.getenv("consumer_key")

consumer_secret <- Sys.getenv("consumer_secret")

access_token <- Sys.getenv("token")

access_secret <- Sys.getenv("secret")

setup_twitter_oauth(consumer_key,consumer_secret,
                    access_token,access_secret)

## create tweets
tweet_dat <- latest_dat %>%
  mutate(differenz_zum_vortag_label = scales::label_number()(differenz_zum_vortag) %>% str_remove_all("\\.0")) %>%
  mutate(prozent_zum_vortag =  (differenz_zum_vortag)/(impfungen_kumulativ-differenz_zum_vortag)*100) %>%
  mutate(prozent_zum_vortag_label = specify_decimal(prozent_zum_vortag, 1)) %>%
  mutate(prozent_geimpft_label = specify_decimal(prozent_geimpft, 1)) %>%
  mutate(tweet_raw1 = glue::glue("{bundesland_iso}: {prozent_geimpft_label}")) %>%
  mutate(tweet_raw2 = glue::glue("{bundesland_iso}: {impfungen_kumulativ_label}")) %>%
  mutate(tweet_raw3 = glue::glue("{bundesland_iso}: +{differenz_zum_vortag_label}"))  %>%
  mutate(tweet_raw4 = glue::glue("{bundesland_iso}: +{prozent_zum_vortag_label}%")) %>%
  mutate_all(~str_replace_all(.x, "NA", "--")) %>%
  mutate_all(~ifelse(str_detect(.x, "--"), str_remove_all(.x, "\\+|%"), .x))

tweet1 <- tweet_dat %>%
  summarise(tweet1 = paste0(tweet_raw1, collapse = "\n")) %>%
  pull(tweet1) %>%
  paste0(glue::glue("Impfdosen pro 100 Einwohner ({current_day}):\n\n"), .)

tweet2 <- tweet_dat %>%
  summarise(tweet2 = paste0(tweet_raw2, collapse = "\n")) %>%
  pull(tweet2) %>%
  paste0(glue::glue("Impfdosen verabreicht ({current_day}):\n\n"), .)

tweet3 <- tweet_dat %>%
  summarise(tweet3 = paste0(tweet_raw3, collapse = "\n")) %>%
  pull(tweet3) %>%
  paste0(glue::glue("Differenz zum Vortag ({latest_day}):\n\n"), .)

tweet4 <- tweet_dat %>%
  summarise(tweet4 = paste0(tweet_raw4, collapse = "\n")) %>%
  pull(tweet4) %>%
  paste0(glue::glue("Prozent Wachstum seit Vortag ({latest_day}):\n\n"), .)

## tweet them
twitteR::tweet(text = tweet1, mediaPath = "img/infobox1_de.png", bypassCharLimit = T)

Sys.sleep(10)

twitteR::tweet(text = tweet2, mediaPath = "img/infobox1_de.png", bypassCharLimit = T)


Sys.sleep(10)

twitteR::tweet(text = tweet3, mediaPath = "img/infobox2_de.png", bypassCharLimit = T)

Sys.sleep(10)

twitteR::tweet(text = tweet4, mediaPath = "img/infobox2_de.png", bypassCharLimit = T)

Sys.sleep(10)

twitteR::tweet(text = glue::glue("Impfdosen verabreicht ({current_day}):\n"),
               mediaPath = "img/total-zeit_de.png", bypassCharLimit = T)

Sys.sleep(10)

twitteR::tweet(text = glue::glue("Impfdosen pro 100 Einwohner ({current_day}):\n"),
                 mediaPath = "img/prozent-zeit_de.png", bypassCharLimit = T)


