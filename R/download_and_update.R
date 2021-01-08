library(readr)
library(vaccc19de)

# download
xlsx_path <- rki_download_xlsx("data/raw")

# store raw data
csv_paths <- rki_extract_sheet_csvs(xlsx_path, "data/raw")

# extract
rki_data <- rki_extract_cumulative_data(xlsx_path)

# update time series
# read in existing data
cumulative <- readr::read_csv("data/cumulative_time_series.csv")

# check whether the new Datenstand is already in the time series data
if (unique(rki_data$ts_datenstand) == max(cumulative$ts_datenstand)) {
  # no new data
  print(glue::glue("No new data. Skipping update."))
  readr::write_lines("no_update", "/tmp/ts_datenstand.txt")
  readr::write_lines("no_update", "/tmp/ts_download.txt")
  fs::file_delete(c(xlsx_path, csv_paths))
  quit(status = 0, save = "no")
}

# append
cumulative <- cumulative %>%
  dplyr::bind_rows(rki_data)

debugonce(rki_extract_diffs2)

# calculate diffs
diffs <- rki_extract_diffs2(cumulative)

rki_extract_diffs2 <- function(cumulative_data) {

  # grouped lag
  calc_lag <- function(col) {
    lag_col <- dplyr::lag(col)
    # NA handling
    # replace NA's in lag_col with 0 so that subtracting NA from a number does not result in NA
    # we keep NAs in the original column so that when a value is NA, it is kept as such in the decumulated
    # data (could be meaningful)
    lag_col[is.na(lag_col)] <- 0
    diff <- col - lag_col # subtract
    diff[1] <- col[1] # so that first value is the "baseline" and not NA
    return(diff)
  }

  decumulated_data <- cumulative_data %>%
    dplyr::arrange(bundesland, bundesland_iso, ts_datenstand) %>%
    dplyr::group_by(bundesland, bundesland_iso) %>%
    dplyr::mutate(dplyr::across(dplyr::starts_with(c("indikation", "medizinische_indikation", "berufliche_indikation", "pflegeheim")), calc_lag, .names = "{.col}_neu"))

  decumulated_data <- decumulated_data %>%
    dplyr::rename(impfungen_neu = differenz_zum_vortag) %>%
    dplyr::select(dplyr::starts_with("ts"), bundesland, bundesland_iso, dplyr::ends_with("_neu"), notes, dplyr::starts_with("x")) %>% # TODO: remove last statement as soon as #9 is fixed
    dplyr::arrange(ts_datenstand, bundesland)

  return(decumulated_data)
}


cumulative %>% readr::write_csv("data/cumulative_time_series.csv")
diffs %>% readr::write_csv("data/diffs_time_series.csv")

# write out ts_download and ts_datenstand for gh actions
readr::write_lines(format(unique(rki_data$ts_datenstand), "%Y-%m-%dT%H%M%S", tz = "Europe/Berlin"), "/tmp/ts_datenstand.txt")
readr::write_lines(format(unique(rki_data$ts_download), "%Y-%m-%dT%H%M%S", tz = "Europe/Berlin"), "/tmp/ts_download.txt")
