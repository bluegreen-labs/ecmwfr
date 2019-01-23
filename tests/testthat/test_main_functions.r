# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

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
                   area = "73.5/-27/33/45",
                   format = "netcdf",
                   target = "tmp.nc")

# set password using encrypted key
# if provided, otherwise just continue
# assuming a valid keychain value (see
# additional check below)
# Using environment variables (travis)
wf_set_key(email = Sys.getenv("ECMWFAPIEMAIL"),
           key   = Sys.getenv("ECMWFAPIKEY"))

# Check if a password is not set. This traps the inconsistent
# behavious between systems while accomodating for encrypted
# keys on Travis CI. Mostly this deals with the sandboxed
# checks on linux which can't access the global keychain or
# environmental variables (hence fail to retrieve the api key).
# This also allows for very basic checks on r-hub.
# No checks should be skiped on either Travis CI or OSX.
if(any(c(nchar(Sys.getenv("ECMWFAPIEMAIL")), nchar(Sys.getenv("ECMWFAPIKEY"))) == 0)) {
  skip_check <- TRUE
} else {
  skip_check <- try(wf_get_key(email = Sys.getenv("ECMWFAPIEMAIL")))
  skip_check <- inherits(skip_check, "try-error")
}

# check keychain management
test_that("set, get secret key",{
  skip_if(skip_check)
  expect_silent(wf_set_key(email = "johndoe@hotmail.com",
                           key = "XXX"))
  expect_output(str(wf_get_key(email = "johndoe@hotmail.com")))
})

test_that("test dataset function", {
  skip_if(skip_check)
  expect_output(str(wf_datasets(email = Sys.getenv("ECMWFAPIEMAIL"))))
})

test_that("test dataset function - no login", {
  expect_error(wf_datasets())
})

test_that("test services function", {
  skip_if(skip_check)
  expect_output(str(wf_services(email = Sys.getenv("ECMWFAPIEMAIL"))))
})

test_that("test services function - no login", {
  expect_error(wf_services())
})

test_that("test user info function", {
  skip_if(skip_check)
  expect_output(str(wf_user_info(email = Sys.getenv("ECMWFAPIEMAIL"))))
})

test_that("test user info function - no login", {
  expect_error(wf_user_info())
})

test_that("test request (transfer) function", {
  skip_if(skip_check)
  expect_message(wf_request(
    email = Sys.getenv("ECMWFAPIEMAIL"),
    transfer = TRUE,
    request = my_request,
    time_out = 60))
})

test_that("test request (transfer) function - time out", {
  skip_if(skip_check)
  expect_output(str(wf_request(
    email = Sys.getenv("ECMWFAPIEMAIL"),
    transfer = TRUE,
    request = my_request,
    time_out = 1)))
})

test_that("test request (transfer) function - no transfer", {
  skip_if(skip_check)
  ct <- wf_request(
    email = Sys.getenv("ECMWFAPIEMAIL"),
    transfer = FALSE,
    request = my_request)

  expect_output(str(ct))
  expect_message(wf_delete(email = Sys.getenv("ECMWFAPIEMAIL"),
                           url = ct$href))
})

test_that("test request (transfer) function - no email", {
  expect_error(wf_request())
})

test_that("test transfer function - no login", {
  expect_error(wf_transfer())
})

test_that("test request (transfer) function", {
  skip_if(skip_check)
  expect_message(wf_request(
    email = Sys.getenv("ECMWFAPIEMAIL"),
    transfer = TRUE,
    request = my_request,
    time_out = 180))
})

test_that("test delete function - no login", {
  expect_error(wf_delete())
})

test_that("test request (transfer) function - larger download", {
  skip_if(skip_check)

  # large request
  large_request <- list(stream = "oper",
                 levtype = "sfc",
                 param = "167.128",
                 dataset = "interim",
                 step = "0",
                 grid = "0.75/0.75",
                 time = "00",
                 date = "2014-07-01/to/2015-07-02",
                 type = "an",
                 class = "ei",
                 area = "50/10/61/21",
                 format = "netcdf",
                 target = "tmp.nc")

  expect_message(wf_request(
    email = Sys.getenv("ECMWFAPIEMAIL"),
    transfer = TRUE,
    request = large_request,
    time_out = 300))
})
