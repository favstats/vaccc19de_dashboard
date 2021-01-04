library(rvest)
library(tidyverse)
library(janitor)

pop_dat <- read_html("https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Bevoelkerungsstand/Tabellen/bevoelkerung-nichtdeutsch-laender.html") %>%
  html_table(fill = T) %>%
  .[[1]] %>%
  janitor::clean_names() %>%
  slice(4:19) %>%
  select(1:2) %>%
  rowwise() %>%
  mutate(insgesamt = str_extract_all(insgesamt, "\\d") %>% unlist %>% paste0(collapse = "") %>% as.numeric) %>%
  rename(bundesland = lander)

saveRDS(pop_dat, file = "data/pop_dat.RDS")
