

library(tidyverse)

source("R/utils.R")

# raw_dat <- read_csv("data/cumulative_time_series.csv")

raw_dat <- read_csv("https://raw.githubusercontent.com/ard-data/2020-rki-impf-archive/master/data/2_csv/all.csv")

rki_dat <- raw_dat %>%
  filter(metric %in% c("impfungen_kumulativ", "differenz_zum_vortag")) %>%
  pivot_wider(names_from = metric, values_from = value) %>%
  rename(bundesland_iso = region) %>%
  left_join(vaccc19de::BUNDESLAND_TO_ISO) %>%
  mutate(bundesland = ifelse(bundesland_iso == "DE", "Deutschland", bundesland))


## population data (see get_pop_dar.R)
pop_dat <- readRDS("data/pop_dat.RDS")

## join in pop_dat
rki_dat <- rki_dat %>%
  left_join(pop_dat) %>%
  mutate(prozent_geimpft = impfungen_kumulativ/insgesamt*100) %>%
  rename(day = date)

## some common colors across plots
bundesland_colors <- c(colorspace::qualitative_hcl(16, palette = "Dark 3", rev = T), "#000000")

##combine color dat with rki_dat
rki_dat <- rki_dat %>%
  distinct(bundesland) %>%
  mutate(colors = bundesland_colors) %>%
  right_join(rki_dat) %>%
  mutate(prozent_geimpft_label = specify_decimal(prozent_geimpft, 2)) %>%
  mutate(impfungen_kumulativ_label = scales::label_number()(impfungen_kumulativ) %>% str_remove_all("\\.0")) #%>%
# mutate(notes = ifelse(stringi::stri_startswith_fixed(notes, "("),
#                       str_remove(notes, "\\("),
#                       notes),
#        notes = ifelse(stringi::stri_endswith_fixed(notes, ")") ,
#                       str_sub(notes, 1, str_length(notes)-1),
#                       notes),
#        notes = ifelse(!stringi::stri_endswith_fixed(notes, "\\.") ,
#                       paste0(notes, "."),
#                       notes))

## save rki_dat temporarily for internal use
saveRDS(rki_dat, file = "data/rki_dat.RDS")

rmarkdown::render_site("Rmd/de", quiet = F)
rmarkdown::render_site("Rmd/en", quiet = F)

## create redirect page
dir.create("docs/de")
c('<!DOCTYPE html>',
  '<html>',
  '<head>',
  '<meta http-equiv="refresh" content="0; url=https://favstats.github.io/vaccc19de_dashboard">',
  '</head>',
  '</html>') %>%
  cat(file = "docs/de/index.html", sep = "\n")

## render readme
rmarkdown::render("README.Rmd")

## for some reason it always generates an HTML too so delete it
file.remove("README.html")

file.copy("icon/favicon.svg", to = "docs/favicon.svg", overwrite = T)
file.copy("icon/favicon.svg", to = "docs/en/favicon.svg", overwrite = T)
file.copy("icon/favicon.svg", to = "docs/de/favicon.svg", overwrite = T)


# notes_dat <- rki_dat %>%
#   drop_na(notes) %>%
#   select(bundesland, bundesland_iso, ts_datenstand, notes)
#
# write_csv(notes_dat, file = "data/notes_dat.csv")
