#' ECMWF data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}.
#' Note that the function will do some basic checks on the \code{request} input
#' to identify possible problems.
#'
#' Two sorts of requests are accepted, a simple data request based upon the
#' available data in the (raw) CDS repository, and a workflow request which
#' forwards an anonymous python function to the CDS servers and returns its
#' results.
#'
#' The latter advanced use case is non-trivial, as both python and R code is
#' required. However, it allows you to offload costly data operations /
#' aggregation to the ECMWF servers, therefore limiting the amount of data
#' that needs to be transferred.
#'
#' A detailed summary of the use of the python API underpinning the CDS Toolbox
#' (Editor) these operations is beyond the scope of this package. We refer to
#' the [CDS Toolbox manual](https://cds.climate.copernicus.eu/toolbox/doc/api.html),
#' and the small example included in the
#' [vignettes](https://bluegreen-labs.github.io/ecmwfr/articles/cds_workflow_vignette.html).
#'
#' @param user user (email address or ID) provided by the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default =
#' \code{3*3600} seconds).
#' @param retry polling frequency of submitted request for downloading (default =
#' \code{30} seconds).
#' @param transfer logical, download data TRUE or FALSE (default = TRUE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF APIs page
#' @param job_name optional name to use as an RStudio job and as output variable
#'  name. It has to be a syntactically valid name.
#' @param verbose show feedback on processing
#' @import uuid
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
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' request <- list(stream = "oper",
#'    levtype = "sfc",
#'    param = "167.128",
#'    dataset = "interim",
#'    step = "0",
#'    grid = "0.75/0.75",
#'    time = "00",
#'    date = "2014-07-01/to/2014-07-02",
#'    type = "an",
#'    class = "ei",
#'    area = "50/10/51/11",
#'    format = "netcdf",
#'    target = "tmp.nc")
#'
#' # demo query
#' wf_request(request = request, user = "test@mail.com")
#'
#' # Run as an RStudio Job. When finished, will create a
#' # variable named "test" in your environment with the path to
#' # the downloaded file.
#' wf_request(request = request, user = "test@mail.com", job_name = "test")
#'}

wf_request <- function(
    request,
    user,
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

  if (!is.list(request) | is.character(request)) {
    stop(
      "`request` must be a named list. \n",
      "If you are passing the user as first argument, notice that argument ",
      "order was changed in version 1.1.1."
    )
  }

  # check the login credentials
  if (missing(request)) {
    stop("Please provide ECMWF or CDS login credentials and data request!")
  }

  # check for user
  if (missing(user)){
    stop("Missing user credentials, please provide a valid user/ID!")
  }

  # Guessing credentials/service
  service_info <- guess_service(request, user)

  if (verbose)
  {
    message("Requesting data to the ",
            service_info$service,
            " service with username ",
            service_info$user)
  }

  # split out data
  service <- service_info$service
  url <- service_info$url

  # Select the appropriate service
  service <- switch(
    service,
    webapi = webapi_service,
    cds = cds_service,
    cds_workflow = cds_workflow,
    ads = ads_service
    )

  # Create request and submit to service
  request <- service$new(
    request = request,
    user = service_info$user,
    url = service_info$url,
    retry = retry,
    path = path
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
    }
    message("Transfer was not successfull - please check your request later at:")
    message(request$get_url())
  }

  return(request)
}
