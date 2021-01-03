

library(tidyverse)

source("R/utils.R")

rki_dat <- read_csv("data/cumulative_time_series.csv")

## population data
pop_dat <- readRDS("data/pop_dat.RDS")

rki_dat <- rki_dat %>%
  left_join(pop_dat) %>%
  mutate(prozent_geimpft = impfungen_kumulativ/insgesamt*100) %>%
  mutate(day = lubridate::as_date(ts_datenstand))

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

current_day <- max(rki_dat$day, na.rm = T)

if(current_day > lubridate::as_date(read_lines("last_update.txt"))){
  updated_data <- T

  saveRDS(rki_dat, file = "data/rki_dat.RDS")
} else {
  cat(as.character(current_day), file = "last_update.txt")

  updated_data <- F
}



if(updated_data){

  ## cleanup docs because they always cause merge conflicts
  cleanup_docs <- dir("docs", full.names = T, recursive = T) %>%
    discard(~str_detect(.x, "docs/de/"))

  cleanup_docs %>%
    walk(file.remove)

  rmarkdown::render_site("site/en")
  rmarkdown::render_site("site/de")
  rmarkdown::render("README.Rmd")
  file.remove("README.html")

  R.utils::copyDirectory("site/en/_site", "docs/en", recursive = T, overwrite = T)
  R.utils::copyDirectory("site/de/_site", "docs", recursive = T, overwrite = T)
  # R.utils::copyDirectory("site/de/", "site/en/")

  ## cleanup sites because they always cause merge conflicts
  unlink("site/en/_site", recursive = T, force = T)
  unlink("site/de/_site", recursive = T, force = T)



}
