# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

# format request (see below)
my_request <- list(
  stream = "oper",
  levtype = "sfc",
  param = "165.128",
  dataset = "interim",
  step = "0",
  grid = "0.75/0.75",
  time = "00",
  date = "2014-07-01",
  type = "an",
  class = "ei",
  area = "51/0/50/1",
  format = "netcdf",
  target = "tmp.nc"
)

# is the server reachable
server_check <- !ecmwfr:::ecmwf_running(ecmwfr:::wf_server(service = "webapi"))

# if server is up, create login
if(!server_check){
  key <- system("echo $WEBAPI", intern = TRUE)
  if(key != "" & key != "$WEBAPI"){
    try(wf_set_key(
      user = "info@bluegreenlabs.org",
      key = key,
      service = "webapi"
    ))
  }
  rm(key)

  login_check <- try(
    wf_get_key(
      user = "info@bluegreenlabs.org"),
    silent = TRUE)
  login_check <- inherits(login_check, "try-error")
} else {
  login_check <- TRUE
}

test_that("set, get secret key",{
  skip_on_cran()
  skip_if(login_check)

  # check retrieval
  expect_output(str(wf_get_key(user = "info@bluegreenlabs.org")))
})

test_that("test dataset function", {
  skip_on_cran()
  skip_if(login_check)
  expect_output(str(wf_datasets(user = "info@bluegreenlabs.org")))
})

test_that("test dataset function - no login", {
  skip_on_cran()
  skip_if(login_check)
  expect_error(wf_datasets())
})

test_that("list datasets webapi",{
  skip_on_cran()
  skip_if(login_check)
  expect_output(str(wf_datasets(user = "info@bluegreenlabs.org",
                                service = "webapi")))
})

test_that("test services function", {
  skip_on_cran()
  skip_if(login_check)

  expect_output(str(wf_services(user = "info@bluegreenlabs.org")))
})

test_that("test services function - no login", {
  skip_on_cran()
  skip_if(login_check)

  expect_error(wf_services())
})

test_that("test user info function", {
  skip_on_cran()
  skip_if(login_check)
  expect_output(str(wf_user_info(user = "info@bluegreenlabs.org")))
})

test_that("test user info function - no login", {
  skip_on_cran()
  skip_if(login_check)
  expect_error(wf_user_info())
})

test_that("test request (transfer) function", {
  skip_on_cran()
  skip_if(login_check)
  expect_type(
    wf_request(
      user = "info@bluegreenlabs.org",
      transfer = TRUE,
      request = my_request
      ),
    "character"
  )
})

test_that("test request (transfer) function", {
  skip_on_cran()
  skip_if(login_check)

  # create new output dir in tempdir()
  path <- file.path(tempdir(),"/test/")
  dir.create(path = path)

  expect_message(wf_request(
    user = "info@bluegreenlabs.org",
    transfer = TRUE,
    request = my_request,
    path = path)
  )
})

test_that("test request (transfer) function - time out", {
  skip_on_cran()
  skip_if(login_check)

  expect_output(str(wf_request(
    user = "info@bluegreenlabs.org",
    transfer = TRUE,
    request = my_request,
    time_out = 1)))
})

test_that("test request (transfer) function - no transfer", {
  skip_on_cran()
  skip_if(login_check)

  ct <- wf_request(
    user = "info@bluegreenlabs.org",
    transfer = FALSE,
    request = my_request)
  ct <- ct$get_url()

  expect_output(str(ct))
  expect_message(
    wf_delete(
    user = "info@bluegreenlabs.org",
    url = ct)
    )

  ct <- wf_request(
    user = "info@bluegreenlabs.org",
    transfer = FALSE,
    request = my_request)
  ct <- ct$get_url()

  expect_silent(
    wf_delete(user = "info@bluegreenlabs.org",
                          url = ct,
                          verbose = FALSE)
    )
})

test_that("test request (transfer) function - no email", {
  skip_on_cran()
  skip_if(login_check)

  expect_error(wf_request())
})

test_that("test transfer function - no login", {
  skip_on_cran()
  skip_if(login_check)

  expect_error(wf_transfer())
})

test_that("list datasets webapi",{
  skip_on_cran()
  skip_if(login_check)

  expect_output(str(wf_datasets(user = "info@bluegreenlabs.org",
                                service = "webapi")))
  expect_output(str(wf_datasets(user = "info@bluegreenlabs.org",
                                service = "webapi",
                                simplify = FALSE)))
})

test_that("test request (transfer) function", {
  skip_on_cran()
  skip_if(login_check)

  expect_message(
    wf_request(
      user = "info@bluegreenlabs.org",
      transfer = TRUE,
      request = my_request,
      time_out = 180)
  )
})

# webapi product info
test_that("check product info",{
  skip_on_cran()
  skip_if(login_check)

  expect_output(str(
    wf_product_info(dataset = "interim",
                    user = "info@bluegreenlabs.org",
                    service = "webapi",
                    simplify = FALSE)))
})

test_that("test delete function - no login", {
  skip_on_cran()
  skip_if(login_check)

  expect_error(wf_delete())
})

test_that("check request - no dataset field", {
  skip_on_cran()
  skip_if(login_check)

  my_request <- list(stream = "oper",
                     levtype = "sfc",
                     param = "167.128",
                     step = "0",
                     grid = "0.75/0.75",
                     time = "00",
                     date = "2014-07-01",
                     type = "an",
                     class = "ei",
                     area = "51/0/50/1",
                     format = "netcdf")
  expect_error(
    wf_check_request(
      user = "info@bluegreenlabs.org",
      request = my_request)
  )
})

test_that("check request - bad request type", {
  skip_on_cran()
  skip_if(login_check)


  my_request <- "xyz"
  expect_error(
    wf_check_request(
      user = "info@bluegreenlabs.org",
      request = my_request)
  )
})

test_that("check mars request - no target", {
  skip_on_cran()
  skip_if(login_check)


  my_request <- list(stream = "oper",
                     levtype = "sfc",
                     param = "167.128",
                     dataset = "mars",
                     step = "0",
                     grid = "0.75/0.75",
                     time = "00",
                     date = "2014-07-01",
                     type = "an",
                     class = "ei",
                     area = "50/10/61/21",
                     format = "netcdf")
  expect_error(
    wf_check_request(
      user = "info@bluegreenlabs.org",
      request = my_request)
  )
})

test_that("check request - no netcdf grid specified", {
  skip_on_cran()
  skip_if(login_check)

  my_request <- list(stream = "oper",
                     levtype = "sfc",
                     param = "167.128",
                     dataset = "mars",
                     step = "0",
                     time = "00",
                     date = "2014-07-01",
                     type = "an",
                     class = "ei",
                     area = "50/10/55/15",
                     format = "netcdf")
  expect_error(
    wf_check_request(
      user = "info@bluegreenlabs.org",
      request = my_request)
  )
})

test_that("check request - bad credentials", {
  skip_on_cran()
  skip_if(login_check)

  my_request <- list(stream = "oper",
                     levtype = "sfc",
                     param = "167.128",
                     dataset = "interim",
                     step = "0",
                     grid = "0.75/0.75",
                     time = "00",
                     date = "2014-07-01",
                     type = "an",
                     class = "ei",
                     area = "50/10/61/21",
                     format = "netcdf",
                     target = "tmp.nc")
  expect_error(
    wf_check_request(
      user = "zzz@zzz.zzz",
      request = my_request)
  )
})

test_that("job_name has to be valid", {
  skip_on_cran()
  skip_if(login_check)

  my_request <- list(stream = "oper",
                     levtype = "sfc",
                     param = "167.128",
                     dataset = "interim",
                     step = "0",
                     grid = "0.75/0.75",
                     time = "00",
                     date = "2014-07-01",
                     type = "an",
                     class = "ei",
                     area = "50/10/61/21",
                     format = "netcdf",
                     target = "tmp.nc")

  expect_error(
    wf_request(my_request,
               user = "info@bluegreenlabs.org",
               job_name = "1"),
    "job_name '1' is not a syntactically valid variable name.")
})

test_that("batch request works", {
  skip_on_cran()
  skip_if(login_check)

  years <- rep(2017,2)
  requests <- lapply(years, function(y) {
    my_request <- list(stream = "oper",
                       levtype = "sfc",
                       param = "165.128",
                       dataset = "interim",
                       step = "0",
                       grid = "0.75/0.75",
                       time = "00",
                       date = paste0(y, "-07-01"),
                       type = "an",
                       class = "ei",
                       area = "51/0/50/1",
                       format = "netcdf",
                       target = "tmp.nc")

  })

  expect_output(
    wf_request_batch(
      requests,
      user = "info@bluegreenlabs.org"
    )
  )
})
