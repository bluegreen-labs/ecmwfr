# set options
options(keyring_backend="file")

# spoof keyring
if(!("ecmwfr" %in% keyring::keyring_list()$keyring)){
  keyring::keyring_create("ecmwfr", password = "test")
}

login_check <- FALSE

# check if on github
ON_GIT <- ifelse(
  length(Sys.getenv("GITHUB_TOKEN")) <= 1,
  TRUE,
  FALSE
)

# is the server reachable
server_check <- ecmwfr:::ecmwf_running(ecmwfr:::wf_server(service = "cds"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check & ON_GIT) {
  user <-try(
      wf_set_key(
        user = "2088",
        key = Sys.getenv("CDS"),
        service = "cds"
        )
    )

  # set login check to TRUE so skipped if
  # the user is not created
  login_check <- inherits(user, "try-error")
}

#----- formal checks ----

# Test a basic workflow
test_that("set key", {
  skip_on_cran()
  skip_if(login_check)

  # basic request for data via python
  # one line as indentation matters
  code <-"
import cdstoolbox as ct

@ct.application()
@ct.output.download()
def plot_time_series(var, lon, lat):
    data = ct.catalogue.retrieve(
      'reanalysis-era5-single-levels',
      {
        'variable': '2m_temperature',
        'grid': ['3', '3'],
        'product_type': 'reanalysis',
        'year': ['2008'],
        'month': ['01'],
        'day': ['01'],
        'time': ['00:00', '06:00', '12:00', '18:00'],
      }
    )

    data_sel = ct.geo.extract_point(data, lon=lon, lat=lat)
    data_daily = ct.climate.daily_mean(data_sel)
    return data_daily
"

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

