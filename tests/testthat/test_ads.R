# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

ads_request <- list(
  date = "2003-01-01/2003-01-01",
  format = "netcdf",
  variable = "dust_aerosol_optical_depth_550nm",
  time = "00:00",
  dataset_short_name = "cams-global-reanalysis-eac4",
  target = "download.nc"
)

# ignore SSL (server has SSL issues)
httr::set_config(httr::config(ssl_verifypeer = 0L))

# is the server reachable
server_check <- !ecmwf_running(wf_server(service = "ads"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(!server_check){
  skip_on_cran()
  
  options(keyring_backend="file")
  
  key <- system("echo $ADS", intern = TRUE)
  if(key != "" & key != "$ADS"){
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
})

# ads product info
test_that("check ADS product info",{
  skip_on_cran()
  skip_if(login_check)
  skip_if(server_check)
  expect_output(
    str(wf_product_info("cams-global-reanalysis-eac4",
                        service = "ads",
                        user = "2161")))
})
