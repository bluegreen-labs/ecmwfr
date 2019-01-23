
#' CDS data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}.
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
#' # Specify request, a pressure-level request
#' # for ERA-5 reanalysis data, temperature 850 hPa.
#' # One time step, user-defined sub-area, NetCDF.
#' request_pl <- list(
#'               "dataset"      = "reanalysis-era5-pressure-levels",
#'               "product_type" = "reanalysis",
#'               "format"       = "netcdf",
#'               "variable"     = "temperature",
#'               "pressure_level" = "850",
#'               "year"   = "2000",
#'               "month"  = "04",
#'               "day"    = "04",
#'               "time"   = "00:00",
#'               "area"   = "70/-20/00/60",
#'               "format" = "netcdf",
#'               "target" = "era5-demo.nc")
#'
#' # Request data/download file using 'user = "1234"'.
#' # Note: requires that you have stored the login information
#' # via 'cds_set_key()' (see above).
#' cds_request(user = "1234",           # user ID (for authentification)
#'             request = request_pl,    # the request
#'             transfer = TRUE,         # download the file
#'             path = ".")              # store data in current working directory
#'
#' # Alternatively (as an alternative to use local keyring):
#' # store user information in .cdsapirc and set user = NULL
#' # to use login information from .cdsapirc:
#' cds_request(user = NULL,             # use .cdsapirc
#'             request = request_pl,    # the request
#'             transfer = TRUE,         # download the file
#'             path = ".")              # store data in current working directory
#'
#' # Second request, surface-level (or single-level) request
#' # for ERA-5 reanalysis data, total precipitation.
#' # One time step, user-defined sub-area, NetCDF.
#' request_sf <- list(
#'               "dataset"      = "reanalysis-era5-single-levels",
#'               "product_type" = "reanalysis",
#'               "format"       = "netcdf",
#'               "variable"     = "total_precipitation",
#'               "year"   = "2000",
#'               "month"  = "04",
#'               "day"    = "04",
#'               "time"   = "00:00",
#'               "area"   = "70/-20/00/60",
#'               "format" = "netcdf",
#'               "target" = "era5-demo.nc")
#'
#' # Surface level request, using '.cdsapirc' login file
#' cds_request(user = NULL,             # use .cdsapirc
#'             request = request_sf,    # the request
#'             transfer = TRUE,         # download the file
#'             path = ".")              # store data in current working directory
#'
#'}

cds_request <- function(user, request, transfer = TRUE, path = tempdir(),
                        time_out = 3600,verbose = TRUE) {

  # No user, no fun!
  if(missing(user))
    stop("Please provide CDS user ID (or set user = NULL, see manual)")

  # check the login credentials
  # If 'user == NULL' load user login information from
  # '~/.cdsapirc' file. Else load key via local keyring.
  input_user <- user # We need to keep the original input_user for later!
  # get key from email
  if (is.null(user)) {
    tmp  <- cds_key_from_file(verbose = verbose)
    user <- tmp$user; key <- tmp$key; rm(tmp)
  } else {
    key <- cds_get_key(user)
  }

  # checking request to avoid some of the common problems
  request <- check_request(request)

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

  # Show message if user exits the function (interrupts execution)
  # or as soon as an error will be thrown.
  exit_msg <-  paste("Even after exiting this function your request is still beeing processed!",
               "Visit https://cds.climate.copernicus.eu/cdsapp#!/yourrequests",
               "to manage (downoload, retry, delete) your requests",
               "or to get ID's from previous requests.",
               "Retry downloading as soon as as completed:",
               sprintf("  - wf_transfer(<user>, \"%s\", \"cds\", \"%s\", \"%s\")",
                       ct$request_id, path, request$target),
               "Delete the job upon completion using:",
               sprintf("  - wf_delete(<user>, \"%s\", \"cds\")", ct$request_id),
               sep = "\n  ")
  on.exit(message(sprintf("- Your request has been submitted to CDS.\n  %s", exit_msg)))

  # some verbose feedback
  if(verbose){
    message("- staging data transfer at url endpoint:")
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
  tmp_file <- basename(tempfile("ecmwfr_"))

  # If return ct$state == "completed": transfer
  if ( ct$state == "completed" ) {
    if(verbose) message("- request preparation completed, transfer data\n")
    ct <- wf_transfer(email    = input_user,
                      url      = ct$request_id,
                      type     = "cds",
                      filename = tmp_file,
                      verbose  = verbose)
  } else {
    # keep waiting for the download order to come online
    # with status code 303
    if (verbose) message("- waiting for request to be processed\n")
    while(ct$state != "completed"){

      # exit routine when the time out
      # is reached, create message to consult
      # the ecmwf website to download the data
      # or retain the download url and use
      # wf_transfer()
      if(Sys.time() > time_out){
        message("- Timeout exceeded!")
        message("  Please use the job list to track your jobs at:")
        message("  https://cds.climate.copernicus.eu/cdsapp#!/yourrequests.")
        message("  Finished jobs can be downloaded via the web interface.")
        message("  Retry downloading as soon as as completed:")
        message(sprintf("  - wf_transfer(<user>, \"%s\", \"cds\", \"%s\", \"%s\")",
                        ct$request_id, path, request$target))
        message("  Delete the job upon completion using:")
        message(sprintf("  - wf_delete(<user>, \"%s\", \"cds\")",
                        ct$request_id))
        return(ct)
      }

      if(verbose){
        # let a spinner spin for "retry" seconds
        spinner(as.numeric(ifelse(!is.null(ct$retry), ct$retry, 10)), ct$request_id)
      } else {
        Sys.sleep(as.numeric(ifelse(!is.null(ct$retry), ct$retry, 10)))
      }

      # Loading current state of request
      response <- httr::GET(sprintf("https://cds.climate.copernicus.eu/api/v2/tasks/%s", ct$request_id),
                            httr::authenticate(user, key),
                            encode = "json")
      ct <- httr::content(response)

      # If ct$state is empty: continue
      # If ct$state == "failed": drop error message, return NULL.
      # If ct$state != "completed": continue, else ...
      # ... (state == "completed") start data transfer.
      if(is.null(ct$state)) {
        ct$state <- "wait"; next
      } else if(ct$state == "failed") {
        cds_request_failed(ct); on.exit(); return(NULL)
      } else if(ct$state != "completed") {
        next
      }

      # Start data transfer as ct$state == "completed"
      if(verbose) message("- Starting transfer\n")
      ct <- wf_transfer(email    = input_user,
                        url      = ct$request_id,
                        type     = "cds",
                        filename = tmp_file,
                        verbose  = verbose)
      break # End loop (file downloaded, all fine)
    }
  }

  # Delete on-exit-message
  on.exit()

  # Move file to final location.
  src <- file.path(tempdir(), tmp_file)
  dst <- file.path(path, request$target)
  if(verbose) message(sprintf("- move file: %s -> %s\n", src, dst))
  file.rename(src, dst)

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


cds_request_failed <- function(x) {
  if(!"error" %in% names(x)) {
    message("[!] ERROR: Server returned an error. Return NULL.")
  } else {
    message("[!] ERROR: Server returned an error, return NULL. Reason:")
    for(n in names(x$error)) {
      if(n == "context") next
      message(sprintf("    - %s:  %s", toupper(n), as.character(x$error[[n]])))
    }
    if("context" %in% names(x$error))
      message(sprintf("    - CONTEXT:  %s", as.character(x$error$context)))
  }
  message("\n")
}

