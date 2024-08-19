library(httr)
library(ecmwfr)

request <-
  list(
    inputs = list(
      product_type = 'reanalysis',
      variable = 'geopotential',
      year = '2024',
      month = '03',
      day = '01',
      time = '13:00',
      pressure_level = '1000',
      data_format = 'grib'
    ),
    dataset_short_name = 'reanalysis-era5-pressure-levels',
    target = 'test.grib'
)

# If you have stored your user login information
# in the keyring by calling cds_set_key you can
# call:
file <- wf_request(
  user     = "koen.hufkens@gmail.com",   # user ID (for authentification)
  request  = request,  # the request
  transfer = TRUE,     # download the file
  verbose = FALSE,
  retry = 10,
  path     = "./analysis/"       # store data in current working directory
)

# ADS CODE
# dataset = 'cams-global-radiative-forcings'
# request = {
#   'variable': ['radiative_forcing_of_carbon_dioxide'],
#   'forcing_type': 'instantaneous',
#   'band': ['long_wave'],
#   'sky_type': ['all_sky'],
#   'level': ['surface'],
#   'version': ['2'],
#   'year': ['2018'],
#   'month': ['06']
# }
# target = 'download.grib'
