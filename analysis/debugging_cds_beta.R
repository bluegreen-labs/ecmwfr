library(httr)
library(ecmwfr)

# request <-
#   list(
#     inputs = list(
#       product_type = 'reanalysis',
#       variable = 'geopotential',
#       year = '2024',
#       month = '03',
#       day = '01',
#       time = '13:00',
#       pressure_level = '1000',
#       data_format = 'grib'
#     ),
#     dataset_short_name = 'reanalysis-era5-pressure-levels',
#     target = 'test.grib'
# )
#
# # # If you have stored your user login information
# # # in the keyring by calling cds_set_key you can
# # # call:
# # file <- wf_request(
# #   user     = "koen.hufkens@gmail.com",   # user ID (for authentification)
# #   request  = request,  # the request
# #   transfer = TRUE,     # download the file
# #   verbose = FALSE,
# #   retry = 10,
# #   path     = "./analysis/"       # store data in current working directory
# # )
#
# key <- wf_get_key(user = "koen.hufkens@gmail.com", service = "cds_beta")
#
# #  get the response for the query provided
# response <- httr::VERB(
#   "GET",
#   paste0("https://cds-beta.climate.copernicus.eu/api/v1/account/"),
#   httr::add_headers(
#     "PRIVATE-TOKEN" = key
#   ),
#   encode = "json"
# )


dataset = 'reanalysis-era5-pressure-levels'
request = {
  'product_type': ['reanalysis'],
  'variable': ['geopotential'],
  'year': ['2024'],
  'month': ['03'],
  'day': ['01'],
  'time': ['13:00'],
  'pressure_level': ['1000'],
  'data_format': 'grib',
}
target = 'download.grib'


