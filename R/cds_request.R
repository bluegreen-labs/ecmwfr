
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
  ct <- httr::content(response)

  # Show message if user exits the function.
  exit_msg <- paste("Note that your request has been submitted to CDS.",
               "Even after exiting this function your request is still",
               "beeing processed! Your request ID is:\n\n%2$s\n\n",
               "You can download the file as soon as processed by calling:\n\n",
               "wf_download(\"%s$2\", type = \"cds\")\n\n",
               "Or cancel the request:\n\n",
               "wf_delete(<user>, \"%1$s/tasks/%2$s\", type = \"cds\")\n\n",
               "Visit https://cds.climate.copernicus.eu/cdsapp#!/yourrequests.",
               "to manage (downoload, retry, delete) your requests or",
               "to get ID's from previous requests.", sep = "")
  on.exit(message(sprintf(exit_msg, cds_server(), ct$request_id)))

  # some verbose feedback
  if(verbose){
    message("Staging data transfer at url endpoint:")
  }

  # only return the content of the query
  if(!transfer){
    return(ct)
  }

  # set time-out counter
  time_out <- Sys.time() + time_out

  # Temporary file name, will be used in combination with
  # tempdir() when calling wf_transfer. The final file will
  # be moved to "path" as soon as the download has been finished.
  tmp_file <- basename(tempfile("ecmwfr_", fileext = ".nc"))

  # If return ct$state == "completed": transfer
  if ( ct$state == "completed" ) {
    if(verbose) cat("Request preparation completed, transfer\n")
    ct <- wf_transfer(email    = input_user,
                      url      = ct$request_id,
                      type     = "cds",
                      path     = path,
                      filename = tmp_file,
                      verbose  = verbose)
  } else {
    # keep waiting for the download order to come online
    # with status code 303
    if (verbose) cat("Waiting for request to be processed\n")
    while(ct$state != "completed"){

      # exit routine when the time out
      # is reached, create message to consult
      # the ecmwf website to download the data
      # or retain the download url and use
      # wf_transfer()
      if(Sys.time() > time_out){
        message("Timeout exceeded!")
        message("Please use the job list to track your jobs at:")
        message("https://cds.climate.copernicus.eu/cdsapp#!/yourrequests.")
        message("Finished jobs can be downloaded via the web interface.")
        message("Delete the job using wt_delete() upon completion using")
        message(sprintf("the job id \"%s\"", ct$request_id))
        return(ct)
      }

      if(verbose){
        # let a spinner spin for "retry" seconds
        spinner(as.numeric(ct$retry), ct$request_id)
      } else {
        Sys.sleep(ct$retry)
      }

      # Loading current state of request
      request <- httr::GET(sprintf("https://cds.climate.copernicus.eu/api/v2/tasks/%s", ct$request_id),
                           httr::authenticate(user, key),
                           encode = "json")
      ct <- httr::content(request)

      # If status == completed: download. Else, loop and wait.
      if(is.null(ct$status)) next
      if(ct$status != "completed") next

      if(verbose) cat("- Starting transfer\n")
      ct <- wf_transfer(email    = input_user,
                        url      = ct$request_id,
                        type     = "cds",
                        filename = tmp_file,
                        verbose  = verbose)
    }
  }

  # Delete on-exit message
  on.exit()

  # Copy data from temporary file to final location
  # and delete original, with an exception for tempdir() location.
  # The latter to facilitate package integration.
  if (path != tempdir()) {
    # copy temporary file to final destination
    src <- file.path(tempdir(), tmp_file)
    dst <- file.path(path, request$target)
    if(verbose) cat("Rename file: %s -> %s\n", src, dst)
    file.rename(src, dst)

  } else {
    dst <- file.path(tempdir(), tmp_file)
    message("- file not copied and removed (path == tempdir())")
  }

  # delete the request upon succesful download
  # to free up other download slots
  # Calling 'wf_delete' with 'type = "cds"' and input_user as
  # 'email'.
  wf_delete(email   = input_user,
            url     = ct$href,
            type    = "cds",
            verbose = verbose)

  # return final file name/path
  return(dst)
}

