# Test ancillary functions which help in (batch) downloading

# format request (see below)
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

test_that("create tests archetype", {

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

