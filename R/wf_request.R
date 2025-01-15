#' ECMWF Data Store (DS) request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}.
#' Note that the function will do some basic checks on the \code{request} input
#' to identify possible problems.
#'
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF APIs page
#' @param user user (default = "ecmwf") provided by the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default =
#' \code{3*3600} seconds).
#' @param retry polling frequency of submitted request for downloading (default =
#' \code{30} seconds).
#' @param transfer logical, download data TRUE or FALSE (default = TRUE)
#' @param job_name optional name to use as an RStudio job and as output variable
#'  name. It has to be a syntactically valid name.
#' @param verbose show feedback on processing
#'
#' @return the path of the downloaded (requested file) or the an R6 object
#' with download/transfer information
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(key = "123")
#'
#' request <- list(
#'   dataset_short_name = "reanalysis-era5-pressure-levels",
#'   product_type = "reanalysis",
#'   variable = "geopotential",
#'   year = "2024",
#'   month = "03",
#'   day = "01",
#'   time = "13:00",
#'   pressure_level = "1000",
#'   data_format = "grib",
#'   target = "download.grib"
#' )
#'
#' # demo query
#' wf_request(request = request)
#'
#' # Run as an RStudio Job. When finished, will create a
#' # variable named "test" in your environment with the path to
#' # the downloaded file.
#' wf_request(request = request, job_name = "test")
#'}


wf_request <- function(
    request,
    user = "ecmwfr",
    transfer = TRUE,
    path = tempdir(),
    time_out = 3600,
    retry = 30,
    job_name,
    verbose = TRUE
) {

  if (!missing(job_name)) {
    if (make.names(job_name) != job_name) {
      stop("job_name '",
           job_name,
           "' is not a syntactically valid variable name.")
    }

    # Evaluates all arguments.
    call <- match.call()
    call$path <- path
    call_list <- lapply(call, eval)
    call[names(call_list)[-1]] <- call_list[-1]

    script <- make_script(call = call, name = job_name)
    if (!requireNamespace("rstudioapi", quietly = TRUE)) {
      stop("Jobs are only supported in RStudio.")
    }

    if (!rstudioapi::isAvailable("1.2")) {
      stop(
        "Need at least version 1.2 of RStudio to use jobs. Currently running ",
        rstudioapi::versionInfo()$version,
        "."
      )
    }

    job <- rstudioapi::jobRunScript(
      path = script,
      name = job_name,
      exportEnv = "R_GlobalEnv"
      )

    return(invisible(job))
  }

  # check for request
  if (missing(request)) {
    stop("Please provide ECMWF data request!")
  }

  if (!is.list(request) | is.character(request)) {
    stop(
      "`request` must be a named list. \n"
    )
  }

  # Guessing credentials/service
  service_info <- guess_service(request, user)

  if (verbose){
    message("Requesting data to the ",
            service_info$service,
            " service with username ",
            service_info$user)
  }

  # grab filename
  filename <- file.path(path, request$target)

  # Create request and submit to service
  request <- ds_service$new(
    request = request,
    user = service_info$user,
    service = service_info$service,
    url = service_info$url,
    retry = retry,
    path = path,
    verbose = verbose
    )

  # Submit the request
  request$submit()

  # Only wait for request to finish if transfer == TRUE
  if (transfer) {
    request$transfer(time_out = time_out)
    if (request$is_success()) {

      # download the data to a set file location
      file_location <- request$get_file()

      # delete from queue
      request$delete()

      # return file location
      return(file_location)
    } else {

      # give verbose feedback
      if(verbose){
        exit_message(
          request$get_url(),
          path,
          request$target,
          service_info$service
        )
      }
    }
  } else {

    # give verbose feedback
    if(verbose){
      exit_message(
        request$get_url(),
        path,
        request$target,
        service_info$service
      )
    }
  }

  return(request)
}
