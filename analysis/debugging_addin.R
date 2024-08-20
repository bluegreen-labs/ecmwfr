
request <- list(
  dataset_short_name = "cems-glofas-forecast",
  variable = "river_discharge_in_the_last_24_hours",
  download_format = "zip",
  target = character(0)
)

request <- list(
  dataset_short_name = "reanalysis-era5-pressure-levels",
  product_type = "reanalysis",
  variable = "geopotential",
  year = "2024",
  month = "03",
  day = c("01", "02"),
  time = "13:00",
  pressure_level = "1000",
  data_format = "grib",
  target = "download.grib"
)
