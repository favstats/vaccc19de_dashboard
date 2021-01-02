

library(tidyverse)

source("R/utils.R")

frie_dat <- read_csv("https://raw.githubusercontent.com/friep/vaccc19de_rki_data/main/data/cumulative_time_series.csv")

rki_dat <- dir("data/", full.names = T) %>%
  keep(~str_detect(.x, "csv")) %>%
  purrr::map_dfr(read_csv) %>%
  bind_rows(frie_dat) %>%
  distinct(ts_datenstand, bundesland, .keep_all = T) %>%
  mutate(day = lubridate::as_date(ts_datenstand))

pop_dat <- readRDS("data/pop_dat.RDS")

rki_dat <- rki_dat %>%
  left_join(pop_dat) %>%
  mutate(prozent_geimpft = impfungen_kumulativ/insgesamt*100)


de_dat <- rki_dat %>%
  group_by(day) %>%
  summarise(impfungen_kumulativ = sum(impfungen_kumulativ),
            insgesamt = sum(insgesamt)) %>%
  mutate(prozent_geimpft = impfungen_kumulativ/insgesamt*100) %>%
  mutate(bundesland = "Deutschland")

bundesland_colors <- c(colorspace::qualitative_hcl(16, palette = "Dark 3", rev = T), "#000000")

rki_dat <- rki_dat %>%
  bind_rows(de_dat)

rki_dat <- rki_dat %>%
  distinct(bundesland) %>%
  mutate(colors = bundesland_colors) %>%
  right_join(rki_dat) %>%
  mutate(prozent_geimpft_label = specify_decimal(prozent_geimpft, 2)) %>%
  mutate(impfungen_kumulativ_label = scales::label_number()(impfungen_kumulativ) %>% str_remove_all("\\.0"))

current_day <- max(rki_dat$day, na.rm = T) %>% format.Date("%d.%m.%Y")

if(nrow(rki_dat) > nrow(readRDS("data/rki_dat.RDS"))){
  updated_data <- T

  saveRDS(rki_dat, file = "data/rki_dat.RDS")
} else {
  cat(current_day, file = "last_update.txt")

  updated_data <- F
}



if(!updated_data){

  rmarkdown::render_site("site/en")
  rmarkdown::render_site("site/de")
  rmarkdown::render("README.Rmd")
  file.remove("README.html")

  R.utils::copyDirectory("site/en/_site", "docs/en", recursive = T, overwrite = T)
  R.utils::copyDirectory("site/de/_site", "docs", recursive = T, overwrite = T)
  # R.utils::copyDirectory("site/de/", "site/en/")


  unlink("site/en/_site", recursive = T, force = T)
  unlink("site/de/_site", recursive = T, force = T)

}
# system("git add -A")
# system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
# system("git push")
