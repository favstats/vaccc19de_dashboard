
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))







hc_de_map_motion <- function(data, date = "date", date_label = "date_label",
                             bundesland = "bundesland",
                             value = "perc", label,
                             map, decimals = 0, #tooltip_name,
                             pointformat
                             ){



  ds <- data[,c(date, date_label, bundesland, value)]
  colnames(ds) <- c("date", "date_label", "bundesland", "value")
  ds <- ds %>%
    group_by(bundesland) %>%
    do(item = list(
      bundesland = first(.$bundesland),
      sequence = .$value,
      value = first(.$value))
    ) %>%
    .$item

  high_map <- highcharter::highchart(type = "map") %>%
    highcharter::hc_add_series(
      data = ds,
      name = label,
      mapData = map,
      joinBy = c("name", "bundesland"),
      borderWidth = 0.01,
      tooltip = list(
        valueDecimals = decimals)
    ) %>%
    highcharter::hc_add_theme(highcharter::hc_theme_smpl()) %>%
    highcharter::hc_motion(
      enabled = T,
      axisLabel = "date",
      labels = unique(data$date_label),
      series = 0,
      updateIterval = 50,
      magnet = list(
        round = "floor",
        step = 0.01
      )
    )

  return(high_map)
}

## from here: https://stackoverflow.com/questions/6461209/how-to-round-up-to-the-nearest-10-or-100-or-x
nice_ceiling <- function(x, nice=c(1,2,4,5,6,8,10)) {
  if(length(x) != 1) stop("'x' must be of length 1")
  10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}
