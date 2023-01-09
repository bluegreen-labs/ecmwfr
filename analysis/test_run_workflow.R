library(ecmwfr)

# set your user ID
user <- "2088"

# get key (as normally - hidden from users)
key <- wf_get_key(user = user, service = "cds")

code <- "import cdstoolbox as ct\n\nlayout = {\n    'input_ncols': 3,\n}\n\nvariables = {\n    'Near-Surface Air Temperature': '2m_temperature',\n    'Eastward Near-Surface Wind': '10m_u_component_of_wind',\n    'Northward Near-Surface Wind': '10m_v_component_of_wind',\n    'Sea Level Pressure': 'mean_sea_level_pressure',\n    'Sea Surface Temperature': 'sea_surface_temperature',\n}\n\n\n@ct.application(title='Extract a time series and plot graph', layout=layout)\n@ct.input.dropdown('var', label='Variable', values=variables.keys(), description='Sample variables')\n@ct.input.text('lon', label='Longitude', type=float, default=75., description='Decimal degrees')\n@ct.input.text('lat', label='Latitude', type=float, default=43., description='Decimal degrees')\n@ct.output.livefigure()\ndef plot_time_series(var, lon, lat):\n    \"\"\"\n    Application main steps:\n\n    - set the application layout with 3 columns for the input and output at the bottom\n    - retrieve a variable over a defined time range\n    - select a location, defined by longitude and latitude coordinates\n    - compute the daily average\n    - show the result as a timeseries on an interactive chart\n\n    \"\"\"\n\n    # Time range\n    data = ct.catalogue.retrieve(\n        'reanalysis-era5-single-levels',\n        {\n            'variable': variables[var],\n            'grid': ['3', '3'],\n            'product_type': 'reanalysis',\n            'year': [\n                '2008', '2009', '2010',\n                '2011', '2012', '2013',\n                '2014', '2015', '2016',\n                '2017'\n            ],\n            'month': [\n                '01', '02', '03', '04', '05', '06',\n                '07', '08', '09', '10', '11', '12'\n            ],\n            'day': [\n                '01', '02', '03', '04', '05', '06',\n                '07', '08', '09', '10', '11', '12',\n                '13', '14', '15', '16', '17', '18',\n                '19', '20', '21', '22', '23', '24',\n                '25', '26', '27', '28', '29', '30',\n                '31'\n            ],\n            'time': ['00:00', '06:00', '12:00', '18:00'],\n        }\n    )\n\n    # Location selection\n\n    # Extract the closest point to selected lon/lat (no interpolation).\n    # If wrong number is set for latitude, the closest available one is chosen:\n    # e.g. if lat = 4000 -> lat = 90.\n    # If wrong number is set for longitude, first a wrap in [-180, 180] is made,\n    # then the closest one present is chosen:\n    # e.g. if lon = 200 -> lon = -160.\n    data_sel = ct.geo.extract_point(data, lon=lon, lat=lat)\n\n    # Daily mean on selection\n    data_daily = ct.climate.daily_mean(data_sel)\n\n    fig = ct.chart.line(data_daily)\n\n    return data_daily\n"

# This query works
# single month of mean daily temperature
request = list(
      code = code,
      kwargs = list(
        "lat" = 43,
        "lon" = 75,
        "var" = "Near-Surface Air Temperature"
      ),
      "workflow_name" = "plot_time_series"
    )

# Get the response for the query provided
# from the correct endpoint
response <- httr::PUT(
  sprintf(
    "%s/tasks/services/%s/clientid-%s",
    ecmwfr:::wf_server(service = "cds"),
    # NOTE THE DIFFERENENT ENDPOINT FOR TOOLBOX EDITOR APPS
    gsub("\\.", "/","tool.toolbox.orchestrator.run_workflow"),
    uuid::UUIDgenerate(output = "string")
  ),
  httr::authenticate(user, key),
  httr::add_headers("Accept" = "application/json",
                    "Content-Type" = "application/json"),
  body = request,
  encode = "json"
)

# The returned content, this is not the data
# only where to get the data if successful
ct <- httr::content(response)
print(ct)

# You can reconstitute the URL where to download things
# as such
url <- ecmwfr:::wf_server(id = ct$request_id, service = "cds")

# update the response to see if the download
# is available (you can check this on the CDS page)
# but in the package for normal requests this query
# is cycled until "completed", see below
response <- httr::GET(
  url,
  httr::authenticate(user, key),
  httr::add_headers("Accept" = "application/json",
                    "Content-Type" = "application/json"),
  encode = "json"
)

# grab content from response
ct <- httr::content(response)

print(ct)

# if the response states that it is completed
# grab the location from the response element and
if (ct$state == "completed") {
  download.file(
    ct$result[[1]]$location,
    "./test.nc"
  )
}
