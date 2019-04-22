# Test ancillary functions which help in (batch) downloading

test_that("create tests archetype", {

  # format request
  my_request <- list(stream = "oper",
                     levtype = "sfc",
                     param = "165.128",
                     dataset = "interim",
                     step = "0",
                     grid = "0.75/0.75",
                     time = "00",
                     date = "2014-07-01/to/2014-07-31",
                     type = "an",
                     class = "ei",
                     area = "51/0/50/1",
                     format = "netcdf",
                     target = "tmp.nc")

  # create archetype
  ERA_interim <- wf_archetype(
    list(
      class = "ei",
      dataset = "interim",
      expver = "1",
      levtype = "pl",
      stream = "moda",
      type = "an",
      format = "netcdf",
      date = "20140101",
      grid = "3/3",
      levelist = "1000",
      param = "155.128",
      target = "output"
    ),
    dynamic_fields = c("date", "grid", "levelist")
  )

  # print archetype (test method)
  expect_message(print(ERA_interim))

  # dump things as a string
  expect_output(str(ERA_interim("20100101", "3/3", "200")))

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

  cds <- "c.retrieve(
    'reanalysis-era5-single-levels-monthly-means',
  {
  'format':'netcdf',
  'product_type':'members-monthly-means-of-daily-means',
  'variable':'2m_temperature',
  'year':'1979',
  'month':'01',
  'time':'00:00'
  },
  'download.nc')"

  mars <- 'retrieve,
class=ep,
  dataset=cera20c,
  date=19010101/19010201/19010301/19010401/19010501/19010601/19010701/19010801/19010901/19011001/19011101/19011201,
  expver=1,
  levtype=sfc,
  number=0,
  param=168.128,
  stream=edmm,
  time=00:00:00,
  type=an,
  target="output"'

  expect_is(ecmwfr:::python_to_list(cds), class = "character")
  expect_error(ecmwfr:::python_to_list())
  expect_is(ecmwfr:::MARS_to_list(mars), class = "character")
  expect_error(ecmwfr:::MARS_to_list())

})


