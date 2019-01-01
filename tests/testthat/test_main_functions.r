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

# set password
key <- system("echo $KEY", intern = TRUE)
wf_set_key(email = "koenhufkens@gmail.com",
           key = key)

# check returned decrypted key
test_that("set, get secret key", {
  #skip_on_cran()
  expect_equal(wf_get_key(email = "koenhufkens@gmail.com"), key)
})

test_that("test dataset function", {
  #skip_on_cran()
  expect_output(str(wf_datasets(email = "koenhufkens@gmail.com")))
})

test_that("test dataset function - no login", {
  skip_on_cran()
  expect_error(wf_datasets())
})

test_that("test services function", {
  #skip_on_cran()
  expect_output(str(wf_services(email = "koenhufkens@gmail.com")))
})

test_that("test services function - no login", {
  #skip_on_cran()
  expect_error(wf_services())
})

test_that("test user info function", {
  #skip_on_cran()
  expect_output(str(wf_user_info(email = "koenhufkens@gmail.com")))
})

test_that("test user info function - no login", {
  #skip_on_cran()
  expect_error(wf_user_info())
})

test_that("test request (transfer) function", {
  #skip_on_cran()
  expect_message(wf_request(
    email = "koenhufkens@gmail.com",
    transfer = TRUE,
    request = my_request,
    time_out = 60))
})

test_that("test transfer function - no login", {
  #skip_on_cran()
  expect_error(wf_transfer())
})


test_that("test request (transfer) function", {
  #skip_on_cran()
  expect_message(wf_request(
    email = "koenhufkens@gmail.com",
    transfer = TRUE,
    request = my_request,
    time_out = 60))
})


