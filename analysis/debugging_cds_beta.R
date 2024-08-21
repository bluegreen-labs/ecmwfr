library(httr)
library(ecmwfr)

# CDS
# request <-
#   list(
#       product_type = 'reanalysis',
#       variable = 'geopotential',
#       year = '2024',
#       month = '03',
#       day = '01',
#       time = '13:00',
#       pressure_level = '1000',
#       data_format = 'grib',
#       dataset_short_name = 'reanalysis-era5-pressure-levels',
#       target = 'test.grib'
# )

# # ADS
# request <- list(
#   dataset_short_name = "cams-global-radiative-forcings",
#   variable = "radiative_forcing_of_carbon_dioxide",
#   forcing_type = "instantaneous",
#   band = "long_wave",
#   sky_type = "all_sky",
#   level = "surface",
#   version = "2",
#   year = "2018",
#   month = "06",
#   target = "download.grib"
# )


# CEMS
request <- list(
  dataset_short_name = "cems-glofas-historical",
  hydrological_model = "htessel_lisflood",
  product_type = "consolidated",
  variable = "mean_discharge_in_the_last_24_hours",
  hyear = "2020",
  hmonth = "12",
  hday = "25",
  data_format = "grib",
  system_version = "version_2_1",
  target = "cems.grib"
)

# If you have stored your user login information
# in the keyring by calling cds_set_key you can
# call:
file <- wf_request(
  request  = request,  # the request
  transfer = TRUE,     # download the file
  verbose = TRUE,
  retry = 10,
  path     = "./analysis/"       # store data in current working directory
)
