

library(tidyverse)

source("R/utils.R")

rki_dat <- read_csv("data/cumulative_time_series.csv")

## population data (see get_pop_dar.R)
pop_dat <- readRDS("data/pop_dat.RDS")

## join in pop_dat
rki_dat <- rki_dat %>%
  left_join(pop_dat) %>%
  mutate(prozent_geimpft = impfungen_kumulativ/insgesamt*100) %>%
  mutate(day = lubridate::as_date(ts_datenstand) - 1)

## create German total data
de_dat <- rki_dat %>%
  group_by(day) %>%
  summarise(impfungen_kumulativ = sum(impfungen_kumulativ),
            insgesamt = sum(insgesamt)) %>%
  mutate(prozent_geimpft = impfungen_kumulativ/insgesamt*100) %>%
  mutate(bundesland = "Deutschland")

## some common colors accross plots
bundesland_colors <- c(colorspace::qualitative_hcl(16, palette = "Dark 3", rev = T), "#000000")

## combine bundesland data with German data
rki_dat <- rki_dat %>%
  bind_rows(de_dat)

##combine color dat with rki_dat
rki_dat <- rki_dat %>%
  distinct(bundesland) %>%
  mutate(colors = bundesland_colors) %>%
  right_join(rki_dat) %>%
  mutate(prozent_geimpft_label = specify_decimal(prozent_geimpft, 2)) %>%
  mutate(impfungen_kumulativ_label = scales::label_number()(impfungen_kumulativ) %>% str_remove_all("\\.0")) %>%
  mutate(notes = ifelse(stringi::stri_startswith_fixed(notes, "("),
                        str_remove(notes, "\\("),
                        notes),
         notes = ifelse(stringi::stri_endswith_fixed(notes, ")") ,
                        str_sub(notes, 1, str_length(notes)-1),
                        notes),
         notes = ifelse(!stringi::stri_endswith_fixed(notes, "\\.") ,
                        paste0(notes, "."),
                        notes))

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


notes_dat <- rki_dat %>%
  drop_na(notes) %>%
  select(bundesland, bundesland_iso, ts_datenstand, notes)

write_csv(notes_dat, file = "data/notes_dat.csv")
