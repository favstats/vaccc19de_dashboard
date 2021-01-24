library(vaccc19de)

# all xlsx paths
xlsxs <- list.files("data/raw/", pattern = ".xlsx$", full.names = T)

cumulative_ts <- xlsxs %>%
  purrr::map_dfr(function(path) {
    rki_extract_cumulative_data(path)
  })

diffs_ts <- rki_extract_diffs(cumulative_ts)

readr::write_csv(cumulative_ts, "data/cumulative_time_series.csv")
readr::write_csv(cumulative_ts, "data/diffs_time_series.csv")
