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

# modify request
test_that("modify request tests",{
  expect_output(str(
    wf_modify_request(request = my_request,
                      date = "2014-07-01/to/2014-08-31",
                      area = "73.5/-27/33/46")
  ))

  expect_error(str(
      wf_modify_request(date = "2014-07-01/to/2014-08-31",
                        area = "73.5/-27/33/46")
    ))
})

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
      date = date,
      grid = paste0(res, "/", res),
      levelist = levs,
      param = "155.128",
      target = "output"
      ),
    res = 3
   )

  # dump things as a string
  expect_output(str(ERA_interim("20100101", 3, 200)))

  # tests the method to print the archetype nicely
  expect_output(print(ERA_interim("20100101", 3, 200)))

  # print function call als args and body parameters
  # in a list, no errors allowed
  expect_silent(as.list(ERA_interim))

  # no request provided
  expect_error(str(
    wf_archetype(res = 3)
  ))
})
