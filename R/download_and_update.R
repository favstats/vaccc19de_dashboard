library(readr)

ts_download <- Sys.time()

rki_data <- read_csv("https://raw.githubusercontent.com/ard-data/2020-rki-impf-archive/master/data/2_csv/all.csv")


# update time series
# read in existing data
historic <- readr::read_csv("data/ard_data.csv")

# check whether the new Datenstand is already in the time series data
if (max(rki_data$publication_date) == max(historic$publication_date)) {
  # no new data
  print(glue::glue("No new data. Skipping update."))
  readr::write_lines("no_update", "/tmp/ts_datenstand.txt")
  readr::write_lines("no_update", "/tmp/ts_download.txt")
  quit(status = 0, save = "no")
}

readr::write_csv(rki_data, "data/ard_data.csv")

# write out ts_download and ts_datenstand for gh actions
readr::write_lines(format(max(rki_data$publication_date), "%Y-%m-%dT%H%M%S", tz = "Europe/Berlin"), "/tmp/ts_datenstand.txt")
readr::write_lines(format(ts_download, "%Y-%m-%dT%H%M%S", tz = "Europe/Berlin"), "/tmp/ts_download.txt")
