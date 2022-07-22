# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

# format request (see below)
cds_request <- list(
  "dataset_short_name" = "reanalysis-era5-pressure-levels",
  "product_type"   = "reanalysis",
  "format"         = "netcdf",
  "variable"       = "temperature",
  "pressure_level" = "850",
  "year"           = "2018",
  "month"          = "04",
  "day"            = "04",
  "time"           = "00:00",
  "area"           = "50/9/51/10",
  "format"         = "netcdf",
  "target"         = "era5-demo.nc")

cds_request_faulty <- list(
  "dataset_short_name" = "reanalysis-era5-preure-levels",
  "product_type"   = "reanalysis",
  "format"         = "netcdf",
  "variable"       = "temperature",
  "pressure_level" = "850",
  "year"           = "2018",
  "month"          = "04",
  "day"            = "04",
  "time"           = "00:00",
  "area"           = "50/9/51/10",
  "format"         = "netcdf",
  "target"         = "era5-demo.nc")

# is the server reachable
server_check <- !ecmwfr:::ecmwf_running(ecmwfr:::wf_server(service = "cds"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(!server_check){
  skip_on_cran()

  options(keyring_backend="file")

  key <- system("echo $CDS", intern = TRUE)
  if(key != "" & key != "$CDS"){
    try(
      wf_set_key(user = "2088",
               key = key,
               service = "cds")
      )
  }
  rm(key)

  login_check <- try(wf_get_key(user = "2088",
                                service = "cds"), silent = TRUE)
  login_check <- inherits(login_check, "try-error")
  server_check <- !ecmwf_running(wf_server(service = "cds"))
} else {
  login_check <- TRUE
}

test_that("set key", {
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
  key <- system("echo $CDS", intern = TRUE)
  if(key != "" & key != "$CDS"){
    expect_message(wf_set_key(user = "2088",
               key = key,
               service = "cds"))
  }
  rm(key)
})

test_that("cds datasets returns data.frame or list", {
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
  expect_true(inherits(wf_datasets(user = "2088",
                                   service = "cds",
                                   simplify = TRUE), "data.frame"))
  expect_true(inherits(wf_datasets(user = "2088",
                                   service = "cds",
                                   simplify = FALSE), "list"))
})

# Testing the cds request function
test_that("cds request", {
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)

  # ok transfer
  expect_message(wf_request(user = "2088",
                    request = cds_request,
                    transfer = TRUE))

  # timeout trigger
  expect_message(
    wf_request(user = "2088",
               request = cds_request,
               time_out = -1,
               transfer = TRUE))

  # job test (can't run headless)
  expect_error(
    wf_request(user = "2088",
               request = cds_request,
               transfer = TRUE,
               job_name = "jobtest"))

  # faulty request
  expect_error(wf_request(
    user = "2088",
    request = cds_request_faulty))

  # wrong request
  expect_error(wf_request(user = "2088",
                    request = "xyz",
                    transfer = TRUE))

  # missing request
  expect_error(wf_request(user = "2088",
                          transfer = TRUE))

  # missing user
  expect_message(wf_request(request = cds_request,
                          transfer = TRUE))

  expect_true(inherits(wf_request(user = "2088",
              request = cds_request,
              transfer = FALSE), "list"))
})


# # Expecting error if required arguments are not set:
 test_that("required arguments missing for cds_* functions", {
   skip_on_cran()
   skip_if(login_check)
   skip_if(server_check)

   # CDS dataset (requires at least 'user')
   expect_error(wf_dataset())
   expect_output(str(wf_datasets(user = "2088", service = "cds")))

   # CDS productinfo (requires at least 'user' and 'dataset')
   expect_error(wf_product_info())
   expect_error(wf_product_info(user = "2088",
                                service = "cds",
                                dataset = "foo"))

   # CDS productinfo: product name which is not available
   expect_output(str(wf_product_info(user = "2088",
                                     service = "cds",
                                     dataset = "satellite-methane")))

   # CDS tranfer (forwarded to wf_transfer, requires at least
   # 'user' and 'url)
   expect_error(wf_transfer())
   expect_error(wf_transfer(user = "2088",
                            service = "cds",
                            url = "http://google.com"))

   # CDS transfer with wrong type
   expect_error(wf_transfer(user = "2088",
                            url = "http://google.com",
                            service = "foo"))

   # check product listing
   expect_output(str(wf_product_info("reanalysis-era5-single-levels",
                                     service = "cds",
                                     user = NULL,
                                     simplify = FALSE)))

   expect_output(str(wf_product_info("reanalysis-era5-single-levels",
                                     service = "cds",
                                     user = NULL,
                                     simplify = FALSE)))
})

# check delete routine CDS (fails)
test_that("delete request", {
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
   expect_warning(
     wf_delete(user = "2088",
               service = "cds",
               url = "50340909as"))
})

# CDS product info
test_that("check product info",{
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
  expect_output(
    str(wf_product_info("reanalysis-era5-single-levels",
                        service = "cds",
                        user = NULL)))
})
