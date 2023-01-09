library(ecmwfr)
library(terra) # to visualize things

# set your user ID
user <- "2088"

# get key (as normally - hidden from users)
key <- wf_get_key(user = user, service = "cds")

# This query works
# single month of mean daily temperature
request = list(
  "args" = "",
  kwargs = list(
    params = list(
      kwargs = list(
        "dataset" = "reanalysis-era5-single-levels",
        "product_type" = "reanalysis",
        "variable" = "2m_temperature",
        "statistic" = "daily_mean",
        "year" = "2020",
        "month" = "01",
        "time_zone" = "UTC+00:0",
        "frequency" = "1-hourly",
        "grid" = "0.25/0.25",
        "area" = list(
          lat = list(38, 60),
          lon = list(-20,20)
        )
      ),
      "workflow_name" = "application",
      "realm" = "c3s",
      "project" = "app-c3s-daily-era5-statistics",
      "version" = "master"
    )
  )
)

# Get the response for the query provided
# from the correct endpoint
response <- httr::PUT(
  sprintf(
    "%s/tasks/services/%s/clientid-%s",
    ecmwfr:::wf_server(service = "cds"),
    gsub("\\.", "/","tool.toolbox.orchestrator.workflow"),
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

# if the response states that it is completed
# grab the location from the response element and
if (ct$state == "completed") {
  download.file(
    ct$result[[1]]$location,
    "./test.nc"
  )
}

r <- terra::rast("./test.nc")
terra::plot(r)


