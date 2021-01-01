
unleash_tweets <- function(latest_dat, latest_day, current_day) {

  name <- "MyTotallyAwesomeUniqueApp"

  consumer_key <- Sys.getenv("consumer_key")

  consumer_secret <- Sys.getenv("consumer_secret")

  access_token <- Sys.getenv("token")

  access_secret <- Sys.getenv("secret")


  tempfile1 <- tempfile()
  tempfile2 <- tempfile()



  setup_twitter_oauth(consumer_key,consumer_secret,
                      access_token,access_secret)

  download.file("https://github.com/favstats/vaccc19de_dashboard/raw/main/img/infobox1.png", destfile = tempfile1)
  download.file("https://github.com/favstats/vaccc19de_dashboard/raw/main/img/infobox2.png", destfile = tempfile2)


  tweet_dat <- latest_dat %>%
    mutate(differenz_zum_vortag_label = scales::label_number()(differenz_zum_vortag) %>% str_remove_all("\\.0")) %>%
    mutate(prozent_zum_vortag =  (differenz_zum_vortag)/(impfungen_kumulativ-differenz_zum_vortag)*100) %>%
    mutate(prozent_zum_vortag_label = specify_decimal(prozent_zum_vortag, 1)) %>%
    mutate(prozent_geimpft_label = specify_decimal(prozent_geimpft, 1)) %>%
    mutate(tweet_raw1 = glue::glue("{bundesland_iso}: {prozent_geimpft_label}%")) %>%
    mutate(tweet_raw2 = glue::glue("{bundesland_iso}: {impfungen_kumulativ_label}")) %>%

    mutate(tweet_raw3 = glue::glue("{bundesland_iso}: +{differenz_zum_vortag_label}"))  %>%
    mutate(tweet_raw4 = glue::glue("{bundesland_iso}: +{prozent_zum_vortag_label}%"))

  tweet1 <- tweet_dat %>%
    summarise(tweet1 = paste0(tweet_raw1, collapse = "\n")) %>%
    pull(tweet1) %>%
    paste0(glue::glue("Prozent der Bevölkerung geimpft ({current_day}):\n\n"), .)

  tweet2 <- tweet_dat %>%
    summarise(tweet2 = paste0(tweet_raw2, collapse = "\n")) %>%
    pull(tweet2) %>%
    paste0(glue::glue("Bevölkerung geimpft ({current_day}):\n\n"), .)

  tweet3 <- tweet_dat %>%
    summarise(tweet3 = paste0(tweet_raw3, collapse = "\n")) %>%
    pull(tweet3) %>%
    paste0(glue::glue("Differenz zum Vortag ({latest_day}):\n\n"), .)

  tweet4 <- tweet_dat %>%
    summarise(tweet4 = paste0(tweet_raw4, collapse = "\n")) %>%
    pull(tweet4) %>%
    paste0(glue::glue("Prozent Wachstum seit Vortag ({latest_day}):\n\n"), .)

  twitteR::tweet(text = tweet1, mediaPath = tempfile1, bypassCharLimit = T)

  Sys.sleep(10)

  twitteR::tweet(text = tweet2, mediaPath = tempfile1, bypassCharLimit = T)


  Sys.sleep(10)

  twitteR::tweet(text = tweet3, mediaPath = tempfile2, bypassCharLimit = T)

  Sys.sleep(10)

  twitteR::tweet(text = tweet4, mediaPath = tempfile2, bypassCharLimit = T)
}