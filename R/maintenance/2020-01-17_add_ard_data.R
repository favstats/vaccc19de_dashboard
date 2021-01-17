# so far our approach did not handle it when the RKI updated the data
# without updating the datenstand (see #16)
# hence, I copied the data from the ARD Impfarchiv: https://github.com/ard-data/2020-rki-impf-archive
# in this script i add them to our dataset
library(tidyverse)
paths <- c("data/raw/2021-01-05T154004_impfmonitoring.xlsx", "data/raw/2021-01-13T154005_impfmonitoring.xlsx")

# read in cumulative data
cumulative <- readr::read_csv("data/cumulative_time_series.csv")

new_data <- purrr::map_dfr(paths, function(path) {
    rki_data <- rki_extract_cumulative_data(path)
    rki_extract_sheet_csvs(path, "data/raw")
    rki_data
})

# store datenstands that are duplicated in the old data 
new_data
datenstands <- unique(new_data$ts_datenstand)

# drop existing data for datenstand
before <- nrow(cumulative)
cumulative_new <- cumulative %>% 
    filter(!ts_datenstand %in% datenstands) 

# make sure 32 rows have been dropped
stopifnot(before - nrow(cumulative_new) == 16 * length(datenstands))

# append new data and arrange by date
cumulative_new <- new_data %>% 
    bind_rows(cumulative_new) %>% 
    arrange(ts_datenstand)
stopifnot(nrow(cumulative_tmp) == before)

# extract diff data
diffs <- rki_extract_diffs(cumulative_new)
diffs

# save
readr::write_csv(diffs, "data/diffs_time_series.csv")
readr::write_csv(cumulative_new, "data/cumulative_time_series.csv")
