
# chart_maps <- function(x, download_data = T, mapdata, trans_internal) {
#   hc <- hcmap2(
#     "https://code.highcharts.com/mapdata/countries/nl/nl-all.js",
#     custom_map = mapdata,
#     data = x,
#     download_map_data = F,
#     value = "percentage",
#     joinBy = c("name", "name"),
#     name = trans_internal$plot_tooltip_geo,
#     dataLabels = list(enabled = TRUE, format = "{point.name}"),
#     borderColor = "#FAFAFA",
#     borderWidth = 0.1,
#     tooltip = list(
#       valueDecimals = 2,
#       valueSuffix = "%"
#     )
#   ) %>%
#     hc_colorAxis(
#       minColor = "white",
#       maxColor = unique(x$colorful),
#       min = 0,
#       max = 35
#     )%>%
#     hc_title(
#       text = unique(x$advertiser_name)
#     ) %>%
#     hc_exporting(
#       enabled = TRUE
#     )
#
#   # download_data <<- F
#
#   return(hc)
# }

hcmap2 <- function(map = "custom/world",
                   data = NULL, joinBy = "hc-key", value = NULL,
                   download_map_data = FALSE, custom_map = NULL, ...) {

  url <- "https://code.highcharts.com/mapdata"
  map <- str_replace(map, "\\.js", "")
  map <- str_replace(map, "https://code\\.highcharts\\.com/mapdata/", "")
  mapfile <- sprintf("%s.js", map)

  hc <- highchart(type = "map")

  if(download_map_data) {

    mapdata <- download_map_data(file.path(url, mapfile))

  } else {

    mapdata <- custom_map

  }

  if(is.null(data)) {

    hc <- hc %>%
      highcharter:::hc_add_series.default(
        mapData = mapdata, ...)

  } else {

    stopifnot(joinBy %in% names(data))
    data <- mutate_(data, "value" = value)

    hc <- hc %>%
      highcharter:::hc_add_series.default(
        mapData = mapdata,
        data = list_parse(data), joinBy = joinBy, ...) %>%
      hc_colorAxis(auxpar = NULL)

  }

  hc

}
