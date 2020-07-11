# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

# format request (see below)
ads_request <- list(
  model = "ensemble",
  date = "2020-07-01/2020-07-02",
  format = "netcdf",
  variable = "ammonia",
  level = "0",
  type = "analysis",
  time = "00:00",
  leadtime_hour = "0",
  dataset_short_name = "cams-europe-air-quality-forecasts",
  target = "download.nc"
)

ads_request_faulty <- list(
  model = "ensemble",
  date = "2020-07-01/2020-07-02",
  format = "netcdf",
  variable = "ammonia",
  level = "0",
  type = "analysis",
  time = "00:00",
  leadtime_hour = "0",
  dataset_short_name = "cams-europe-air-quality-fore",
  target = "download.nc"
)

# is the server reachable
server_check <- !ecmwf_running(wf_server(service = "ads"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(!server_check){
  skip_on_cran()
  key <- system("echo $ADS", intern = TRUE)
  if(key != "" | key != "$ADS"){
    wf_set_key(user = "2161",
               key = key,
               service = "ads")
  }
  rm(key)

  login_check <- try(wf_get_key(user = "2161",
                                service = "ads"), silent = TRUE)
  login_check <- inherits(login_check, "try-error")
  server_check <- !ecmwf_running(wf_server(service = "ads"))
} else {
  login_check <- TRUE
}

test_that("ads datasets returns data.frame or list", {
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
  expect_true(inherits(wf_datasets(user = "2161",
                                   service = "ads",
                                   simplify = TRUE), "data.frame"))
  expect_true(inherits(wf_datasets(user = "2161",
                                   service = "ads",
                                   simplify = FALSE), "list"))
})

# Testing the ads request function
test_that("ads request", {
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)

  # ok transfer
  expect_message(wf_request(user = "2161",
                    request = ads_request,
                    transfer = TRUE))

  # timeout trigger
  expect_message(
    wf_request(user = "2161",
               request = ads_request,
               time_out = -1,
               transfer = TRUE))

  # job test (can't run headless)
  expect_error(
    wf_request(user = "2161",
               request = ads_request,
               transfer = TRUE,
               job_name = "jobtest"))

  # faulty request
  expect_error(wf_request(
    user = "2161",
    request = ads_request_faulty))
})

# ads product info
test_that("check ADS product info",{
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
  expect_output(
    str(wf_product_info("cams-europe-air-quality-forecasts",
                        service = "ads",
                        user = "2161")))
})
