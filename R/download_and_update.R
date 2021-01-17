library(readr)
library(vaccc19de)
library(openssl)
library(lubridate)

# download new (?) data
xlsx_path <- rki_download_xlsx("data/raw")

# find latest xlsx file in existing data
# previously, we did comparisons based on the "datenstand" but it turned out
# that this was insufficient because the RKI also sometimes updated the data
# without updating the datenstand, see https://github.com/favstats/vaccc19de_dashboard/issues/16
existing_files <- list.files("data/raw", full.names = TRUE)
newest_existing_i <- existing_files %>% 
  lubridate::ymd_hms() %>% 
  which.max()

# compare hashes of files to see whether they have been saved
incoming_hash <- as.character(openssl::md5(file(xlsx_path)))
newest_existing_hash <- as.character(openssl::md5(file(existing_files[newest_existing_i])))

if (incoming_hash == newest_existing_hash) {
  # no update if hash is the same
  print(glue::glue("No new data. Skipping update."))
  readr::write_lines("no_update", "/tmp/ts_datenstand.txt")
  readr::write_lines("no_update", "/tmp/ts_download.txt")
  fs::file_delete(xlsx_path)
  quit(status = 0, save = "no")
}

# store raw data
csv_paths <- rki_extract_sheet_csvs(xlsx_path, "data/raw")

# extract
rki_data <- rki_extract_cumulative_data(xlsx_path)
new_datenstand <- unique(rki_data$ts_datenstand)

# update time series
# read in existing data
cumulative <- readr::read_csv("data/cumulative_time_series.csv")

# if the datenstand already exists in data, drop existing rows
# this means that the RKI updated the data without updating the Datenstand :rolling_eyes:
if (unique(rki_data$ts_datenstand) %in% cumulative$ts_datenstand) {
  # drop the existing rows 
  cumulative <- cumulative[cumulative$ts_datenstand != new_datenstand, ]
}

# append
cumulative <- cumulative %>%
  dplyr::bind_rows(rki_data)

# calculate diffs
diffs <- rki_extract_diffs(cumulative)

cumulative %>% readr::write_csv("data/cumulative_time_series.csv")
diffs %>% readr::write_csv("data/diffs_time_series.csv")

# write out ts_download and ts_datenstand for gh actions
readr::write_lines(format(unique(rki_data$ts_datenstand), "%Y-%m-%dT%H%M%S", tz = "Europe/Berlin"), "/tmp/ts_datenstand.txt")
readr::write_lines(format(unique(rki_data$ts_download), "%Y-%m-%dT%H%M%S", tz = "Europe/Berlin"), "/tmp/ts_download.txt")
