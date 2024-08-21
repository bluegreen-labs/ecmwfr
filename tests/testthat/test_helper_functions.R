# Test ancillary functions which help in (batch) downloading

test_that("create tests archetype", {
  skip_on_cran()

  # format request
  my_request <- list(
    dataset_short_name = "reanalysis-era5-pressure-levels",
    product_type = "reanalysis",
    variable = "geopotential",
    year = "2024",
    month = "03",
    day = "01",
    time = "13:00",
    pressure_level = "1000",
    data_format = "grib",
    area = c(51, 1, 50, 2),
    target = "download.grib"
  )

  # create archetype
  ERA_interim <- wf_archetype(
    my_request,
    dynamic_fields = c("day")
  )

  # print archetype (test method)
  expect_message(print(ERA_interim))

  # dump things as a string
  expect_output(str(ERA_interim("05")))

  # missing request element
  expect_error(str(wf_archetype(request = list(date = "20140101"),
                                dynamic_fields = "res")
  ))

  # missing dynamic field
  expect_error(str(wf_archetype(request = my_request)))

  # no request provided
  expect_error(str(
    wf_archetype(dynamic_fields = "res")
  ))
})

test_that("test addin",{
  skip_on_cran()

  cds <- "
   dataset = 'reanalysis-era5-pressure-levels'
   request = {
   'product_type': ['reanalysis'],
   'variable': ['temperature'],
   'year': ['2000'],
   'month': ['04'],
   'day': ['04'],
   'time': ['00:00'],
   'pressure_level': ['850'],
   'data_format': 'netcdf',
   'download_format': 'unarchived',
   'area': [70, -20, 60, 30]
   }"

  expect_is(ecmwfr:::python_to_list(cds), class = "character")
  expect_error(ecmwfr:::python_to_list())

})


