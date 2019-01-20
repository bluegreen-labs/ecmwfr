
#' CDS data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}. The function only
#' allows NetCDF downloads, and will override calls for grib data.
#'
#' @param user username you used to register the API key
#' when calling \code{\link[ecmwfr]{cds_set_key}}. Note: can also be set to \code{NULL}
#' to use the \code{.cdsapirc} located in your home directory (if existing).
#' @param request nested list with query parameters following the layout
#' as specified on the CDS API page
#' @param transfer logical, download data \code{TRUE} or \code{FALSE}
#' (default \code{transfer = FALSE})
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default = 3600)
#' @param verbose show feedback on processing
#'
#' @return a download query staging url or a netCDF of data on disk
#'
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{cds_set_key}},
#' \code{\link[ecmwfr]{cds_get_key}},
#' \code{\link[ecmwfr]{cds_key_from_file}},
#' \code{\link[ecmwfr]{wf_transfer}}
#' @export
#' @author Koen Kufkens, Reto Stauffer
#' @examples
#'
#' \donttest{
#' # Use local keyring:
#' cds_set_key(user = "1234", key = "abcd1345foo")
#'
#' # Specify request 
#' era_request <- list(
#'             "dataset" = "reanalysis-era5-pressure-levels",
#'             "product_type" = "reanalysis",
#'             "format" = "netcdf",
#'             "variable" = "temperature",
#'             "pressure_level" = "850",
#'             "year" = "2000",
#'             "month" = "04",
#'             "day" = "04",
#'             "time" = "00:00",
#'             "area" = "70/-20/00/60",
#'             "format" = "netcdf",
#'             "target" = "era5-demo.nc")
#'
#' # Request data/download file using 'user = "1234"'.
#' # Note: requires that you have stored the login information
#' # via 'cds_set_key()' (see above).
#' cds_request(user = "1234",           # user ID (for authentification)
#'             request = era_request,   # the request
#'             transfer = TRUE,         # download the file
#'             path = ".")              # store data in current working directory
#'
#' # (Ugly) demo plot to see if we got what we expect,
#' # requires the ncdf4 library to be installed.
#' nc <- ncdf4::nc_open("era5-demo.nc")
#' image(sort(ncdf4::ncvar_get(nc, "longitude")),
#'       sort(ncdf4::ncvar_get(nc, "latitude")),
#'       ncdf4::ncvar_get(nc, "t"))
#' ncdf4::nc_close(nc)
#'
#' # Alternatively (as an alternative to use local keyring):
#' # store user information in .cdsapirc and set user = NULL
#' # to use login information from .cdsapirc:
#' cds_request(user = NULL,             # use .cdsapirc
#'             request = era_request,   # the request
#'             transfer = TRUE,         # download the file
#'             path = ".")              # store data in current working directory
#'
#' # (Ugly) demo plot to see if we got what we expect,
#' # requires the ncdf4 library to be installed.
#' nc <- ncdf4::nc_open("era5-demo.nc")
#' image(sort(ncdf4::ncvar_get(nc, "longitude")),
#'       sort(ncdf4::ncvar_get(nc, "latitude")),
#'       ncdf4::ncvar_get(nc, "t"))
#' ncdf4::nc_close(nc)
#'}

cds_request <- function(user, request, transfer = TRUE, path = tempdir(),
                        time_out = 3600,verbose = TRUE) {

  # check the login credentials
  if(missing(user)){
    stop("Please provide the user name you used to store the CDS secret key!")
  }

  # We need to keep the original input_user for later!
  input_user <- user
  # get key from email
  if (is.null(user)) {
    tmp  <- cds_key_from_file(verbose = verbose)
    user <- tmp$user; key <- tmp$key; rm(tmp)
  } else {
    key <- cds_get_key(user)
  }

  # force the use of netcdf
  request$format <- "netcdf"
  request$target <- paste0(tools::file_path_sans_ext(request$target), ".nc")

  # get the response from the query provided
  response <- httr::POST(
    sprintf("%s/resources/%s", cds_server(), request$dataset),
    httr::authenticate(user, key),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json"),
    body = request,
    encode = "json"
  )

  # trap general http error
  if(httr::http_error(response)){
    stop(httr::content(response), call. = FALSE)
  }

  # grab content, to look at the status
  cat("XXXXXXXXXXXXXXXXXXXX first content\n")
  ct <- httr::content(response)

  # We need to keep the request_id and location for later!
  print(ct)
  request_id <- ct$request_id
  location   <- ct$location


  print(ct)
  print(url)
  response <- httr::POST(
    sprintf("%s/tasks/%s", cds_server(), request_id),
    httr::authenticate(user, key),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json"),
    encode = "json"
  )
  print(httr:content(response))
  stop('xxxxxxxxxxx----------------------------')

  # some verbose feedback
  if(verbose){
    message("Staging data transfer at url endpoint:")
    message(location)
  }

  # only return the content of the query
  cat("XXXXXXXXXXXXXXXXXXXX no transfer?\n")
  if(!transfer){
    return(ct)
  }

  # set time-out counter
  time_out <- Sys.time() + time_out

  # If return ct$state == "completed": transfer
  if ( ct$state == "completed" ) {
    cat("XXXXXXXXXXXXXXXXXXXX state completed\n")
    if(verbose) cat("Request preparation completed, transfer\n")
    ct <- wf_transfer(email   = input_user,
                      url     = location,
                      type    = "cds",
                      verbose = verbose)
  } else {
    cat("XXXXXXXXXXXXXXXXXXXX state not completed, wayt\n")
    # keep waiting for the download order to come online
    # with status code 303
    if (verbose) cat("Waiting for request to be processed\n")
    while(ct$state != "completed"){
        cat("XXXXXXXXXXXXXXXXXXXX waitng ....\n")

      # exit routine when the time out
      # is reached, create message to consult
      # the ecmwf website to download the data
      # or retain the download url and use
      # wf_transfer()
      if(Sys.time() > time_out){
        message("Please use the MARS job list to track your jobs at:")
        message("https://cds.climate.copernicus.eu/cdsapp#!/yourrequests")
        message("and retry download using wf_transfer() for url:")
        message(ct$location)
        message("Delete the job using cds_delete() upon completion!")
        return(ct)
      }

      if(verbose){
        # let a spinner spin for "retry" seconds
        spinner(as.numeric(ct$retry))
      } else {
        Sys.sleep(ct$retry)
      }

      if(verbose) cat("- Starting transfer\n")
      print("print input_user and location")
      print(input_user)
      print(location)
      ct <- wf_transfer(email   = input_user,
                        url     = location,
                        type    = "cds",
                        verbose = verbose)
      if ( ct[["stateing server for a data transfer"]] == "queued" )
          ct$state = "queed"
      print(ct)
    }
  }

  # Copy data from temporary file to final location
  # and delete original, with an exception for tempdir() location.
  # The latter to facilitate package integration.
  if (path != tempdir()) {

    # create temporary output file
    ecmwf_tmp_file <- file.path(tempdir(), "ecmwf_tmp.nc")

    # copy temporary file to final destination
    if ( verbose ) cat(sprintf("- copy file to: %s\n",
                               file.path(path, request$target)))
    file.copy(ecmwf_tmp_file,
              file.path(path, request$target),
              overwrite = TRUE,
              copy.mode = FALSE)

    # cleanup of temporary file
    invisible(file.remove(ecmwf_tmp_file))
  } else {
    message("- file not copied and removed (path == tempdir())")
  }

  # delete the request upon succesful download
  # to free up other download slots
  # Calling 'wf_delete' with 'type = "cds"' and input_user as
  # 'email'.
  print(ct)
  wf_delete(email = input_user,
            url = sprintf("%s/tasks/%s", cds_server(), request_id),
            type = "cds",
            verbose = verbose)
}

