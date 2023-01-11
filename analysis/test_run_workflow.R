library(ecmwfr)

code <-
"
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
  path = "analysis/",
  transfer = FALSE
  )
