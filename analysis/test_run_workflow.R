
code <- readLines("analysis/era5.py") |>
  paste0(collapse = "\n")

# This query works
# single month of mean daily temperature
request = list(
  code = code,
  kwargs = list(
    "dataset" = "reanalysis-era5-single-levels",
    "product_type" = "reanalysis",
    "variable" = "2m_temperature",
    "statistic" = "daily_mean",
    "year" = "2020",
    "month" = "01",
    "time_zone" = "UTC+00:0",
    "frequency" = "1-hourly",
    "grid" = "0.25/0.25",
    "area" = list(
      lat = list(40, 45),
      lon = list(-0,20)
    )
  ),
  workflow_name = "application",
  target = "test.nc"
)

file <- wf_request(request)

r <- terra::rast(file)
terra::plot(r)
