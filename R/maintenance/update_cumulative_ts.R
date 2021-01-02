# add notes column for all datasets - as per vaccc19de 0.2.0
library(vaccc19de)

# all xlsx paths
xlsxs <- list.files("data/raw/", pattern = ".xlsx$", full.names = T)

cumulative_ts <- xlsxs %>%
  purrr::map_dfr(function(path) {
    rki_extract_cumulative_data(path)
  })

readr::write_csv(cumulative_ts, "data/cumulative_time_series.csv")
