# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)
login_check <- NA

# is the server reachable
server_check <- ecmwfr:::ecmwf_running(ecmwfr:::wf_server(service = "cds"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check){
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
                                service = "cds"),
                     silent = TRUE)
  login_check <- inherits(login_check, "try-error")
}

#----- initial checks should fail locally when not as cran ----

test_that("server up", {
  skip_on_cran()

  message("server is up")
  expect_equal(server_check, TRUE)
})

test_that("login ok", {
  skip_on_cran()

  message("login is ok")
  expect_equal(login_check, FALSE)
})

#----- formal checks ----

# Test a basic workflow
test_that("set key", {
  skip_on_cran()
  skip_if(login_check)

  # basic request for data via python
  code <- "import cdstoolbox as ct\n\n@ct.application()\n@ct.output.download()\n
  def plot_time_series(var, lon, lat):\n    data = ct.catalogue.retrieve(\n
  'reanalysis-era5-single-levels',\n      {\n        'variable': '2m_temperature',\n
  'grid': ['3', '3'],\n        'product_type': 'reanalysis',\n        'year': ['2008'],\n
  'month': ['01'],\n        'day': ['01'],\n        'time': ['00:00', '06:00', '12:00', '18:00'],\n
  }\n    )\n    \n    data_sel = ct.geo.extract_point(data, lon=lon, lat=lat)\n
  data_daily = ct.climate.daily_mean(data_sel)\n    return data_daily"

  request = list(
    code = code,
    kwargs = list(
      var = "Near-Surface Air Temperature",
      lat = 50,
      lon = 20
    ),
    workflow_name = "plot_time_series",
    target = "test.nc"
  )

  expect_output(wf_request(
      request,
      user = "2088"
    )
  )
})

