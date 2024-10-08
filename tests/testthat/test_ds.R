# set options
options(keyring_backend="file")

# spoof keyring
if(!("ecmwfr" %in% keyring::keyring_list()$keyring)){
  keyring::keyring_create("ecmwfr", password = "test")
}

# check if on github
ON_GIT <- ifelse(
  Sys.getenv("GITHUB_ACTION") == "",
  FALSE,
  TRUE
)

# ignore SSL (server has SSL issues)
#httr::set_config(httr::config(ssl_verifypeer = 0L))

cds_request <- list(
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

cds_request_faulty <- list(
  dataset_short_name = "reanalysis-era5-prssre-levels",
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

# is the server reachable
server_check <- ecmwfr:::ecmwf_running(
    paste0(ecmwfr:::wf_server(service = "cds"),"/catalogue/v1/collections/")
  )

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check & ON_GIT){
  user <- try(
      ecmwfr::wf_set_key(
        key = Sys.getenv("CDS"))
      )

  # set login check to TRUE so skipped if
  # the user is not created
  login_check <- inherits(user, "try-error")
} else {

  login_check <- TRUE

  # assume local run
  # if(!inherits(wf_get_key(), "try-error")){
  #   Sys.setenv(CDS = wf_get_key())
  #   login_check <- FALSE
  # } else{
  #   login_check <- TRUE
  # }
}

#----- formal checks ----
test_that("set key", {
  skip_on_cran()
  skip_if(login_check)
  expect_message(wf_set_key(Sys.getenv("CDS")))

  # set system variable and check key again
  Sys.setenv(ecmwfr_PAT=Sys.getenv("CDS"))
  expect_identical(wf_get_key(), Sys.getenv("CDS"))
})

test_that("cds datasets returns data.frame or list", {
  skip_on_cran()
  skip_if(login_check)
  expect_true(inherits(wf_datasets(simplify = TRUE), "data.frame"))
  expect_true(inherits(wf_datasets(simplify = FALSE), "list"))
})

# Testing the cds request function
test_that("cds request", {
  skip_on_cran()
  skip_if(login_check)

  # ok transfer
  expect_message(
    wf_request(
      request = cds_request,
      transfer = TRUE
      )
    )

  # timeout trigger
  expect_message(
    wf_request(
      request = cds_request,
      time_out = -1,
      transfer = TRUE
      )
    )

  # job test (can't run headless)
  if(ON_GIT){
    expect_error(
      wf_request(
        request = cds_request,
        transfer = TRUE,
        job_name = "jobtest"
      )
    )
  }

  # faulty request
  expect_error(
    wf_request(
      request = cds_request_faulty
    )
  )

  # wrong request
  expect_error(
    wf_request(
      request = "xyz",
      transfer = TRUE
      )
    )

  # missing request
  expect_error(wf_request(
    transfer = TRUE
    )
  )

  # R6 testing
  r <- wf_request(
    request = cds_request,
    transfer = FALSE
    )

  # is R6 class
  expect_true(inherits(r, "R6"))
  url <- r$get_url()

  # cleanup
  expect_message(
    r$delete()
  )

  # test delete routine
  expect_error(
    wf_delete(url = "50340909as")
  )

  # delete job with function not method
  r <- wf_request(
    request = cds_request,
    transfer = FALSE
  )

  # is R6 class
  url <- r$get_url()

  expect_message(
    wf_delete(url)
  )
})


# # Expecting error if required arguments are not set:
test_that("required arguments missing for cds_* functions", {
  skip_on_cran()
  skip_if(login_check)

  # submit request
  r <- wf_request(
    request = cds_request,
    transfer = FALSE
  )

  # CDS productinfo (requires at least 'user' and 'dataset')
  expect_error(wf_dataset_info())
  expect_error(wf_dataset_info(dataset = "foo"))

  # THIS FAILS: service too slow?
  # check transfer routine
  # Sys.sleep(120)
  # expect_output(
  #   wf_transfer(
  #     url = r$get_url()
  #     )
  #   )

  # Delete file, check status
  r$delete()
  expect_equal(
    r$get_status(), "deleted"
  )

  # CDS tranfer (forwarded to wf_transfer, requires at least
  # 'user' and 'url)
  expect_error(wf_transfer())
  expect_error(wf_transfer(url = "http://google.com"))

  # check product listing
  expect_output(str(wf_dataset_info(
    "reanalysis-era5-single-levels",
    simplify = FALSE)))
})

test_that("batch request tests", {
  skip_on_cran()
  skip_if(login_check)

  years <- c(2017,2018)
  requests <- lapply(years, function(y) {
    list(
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
      target = paste0(y, "-era5-demo.grib"))
  })

  expect_output(
    wf_request_batch(
    requests,
    retry = 5)
    )

  requests_dup <- lapply(requests, function(r) {
    r$target <- "era5.nc"
    r
  })

  expect_error(wf_request_batch(
    requests_dup)
  )

})
