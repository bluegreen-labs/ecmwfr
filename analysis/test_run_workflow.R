library(ecmwfr)

code <- readLines("analysis/test.py") |>
  paste0(collapse = "\n")

# A query for 2m surface temperature
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

# download the data
file <- wf_request(
  user = "2088",
  request,
  path = "analysis/"
  )

f <- ncdf4::nc_open("analysis/test.nc")
print(f)

t <- ncdf4::ncvar_get(nc = f, "t2m")
ncdf4::nc_close(f)
