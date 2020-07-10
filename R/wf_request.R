#' ECMWF data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}.
#' Note that the function will do some basic checks on the \code{request} input
#' to identify possible problems.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default =
#' \code{3*3600} seconds).
#' @param transfer logical, download data TRUE or FALSE (default = TRUE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF APIs page
#' @param job_name optional name to use as an RStudio job and as output variable
#'  name. It has to be a syntactically valid name.
#' @param verbose show feedback on processing

#' @return a download query staging url or (invisible) filename of the file on
#' your local disc
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

wf_request <- function(request,
                       user,
                       transfer = TRUE,
                       path = tempdir(),
                       time_out = 3600,
                       job_name,
                       verbose = TRUE) {
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

    job <-
      rstudioapi::jobRunScript(path = script,
                               name = job_name,
                               exportEnv = "R_GlobalEnv")
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

  if (missing(user)) {
    user <-
      rbind(
        keyring::key_list(service = make_key_service(c("webapi"))),
        keyring::key_list(service = make_key_service(c("cds"))),
        keyring::key_list(service = make_key_service(c("ads")))
      )
    serv <- make_key_service()
    user <-
      user[substr(user$service, 1,  nchar(serv)) == serv, ][["username"]]
  }

  # checks user login, the request layout and
  # returns the service to use if successful
  wf_check <-
    lapply(user, function(u)
      try(wf_check_request(u, request), silent = TRUE))
  correct <- which(!vapply(wf_check, inherits, TRUE, "try-error"))

  if (length(correct) == 0) {
    stop(
      sprintf(
        "Data identifier %s is not found in Web API, CDS or ADS datasets.
                 Or your login credentials do not match your request.",
        request$dataset_short_name
      ),
      call. = FALSE
    )
  }

  wf_check <- wf_check[[correct]]
  user <- user[correct]

  if (verbose)
  {
    message("Requesting data to the ",
            wf_check$service,
            " service with username ",
            user)
  }

  # split out data
  service <- wf_check$service
  url <- wf_check$url

  # get key
  key <- wf_get_key(user = user, service = service)

  # getting api url: different handling if 'dataset = "mars"',
  # requests to 'dataset = "mars"' require a non-public user
  # account (member states/commercial).

  # depending on the service get the response
  # for the query provided
  if (service == "webapi") {
    response <- httr::POST(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = user,
        "X-ECMWF-KEY" = key
      ),
      body = request,
      encode = "json"
    )
  }

  if (service == "cds"){
    response <- httr::POST(
      sprintf(
        "%s/resources/%s",
        url,
        request$dataset_short_name
      ),
      httr::authenticate(user, key),
      httr::add_headers("Accept" = "application/json",
                        "Content-Type" = "application/json"),
      body = request,
      encode = "json"
    )
  }

  if (service == "ads"){

    # fix strange difference in processing queries
    # from CDS
    body <- request
    body$dataset_short_name <- NULL
    body$target <- NULL
    response <- httr::POST(
      sprintf(
        "%s/resources/%s",
        url,
        request$dataset_short_name
      ),
      httr::authenticate(user, key),
      httr::add_headers("Accept" = "application/json",
                        "Content-Type" = "application/json"),
      body = body,
      encode = "json"
    )
  }

  # trap general http error
  if (httr::http_error(response)) {
    stop(httr::content(response),
         call. = FALSE)
  }

  # grab content, to look at the status
  ct <- httr::content(response)

  # first run is always 202
  if ((service == "cds" | service == "ads")) {
    ct$code <- 202
  }

  # some verbose feedback
  if (verbose) {
    message("- staging data transfer at url endpoint or request id:")
    message("  ", switch(service,
                         "cds" = ct$request_id,
                         "ads" = ct$request_id,
                         "webapi" = ct$href), "\n")
  }

  # only return the content of the query
  if (!transfer) {
    message("  No download requests will be made, however...\n")
    exit_message(
      url = switch(service,
                   "cds" = ct$request_id,
                   "ads" = ct$request_id,
                   "webapi" = ct$href),
      path = path,
      file = request$target,
      service = service
    )
    return(invisible(ct))
  }

  # set time-out counter
  if (verbose) {
    message(sprintf("- timeout set to %.1f hours", time_out / 3600))
  }

  # set time-out
  time_out <- Sys.time() + time_out

  # Temporary file name, will be used in combination with tempdir() when
  # calling wf_transfer.
  tmp_file <- basename(tempfile("ecmwfr_"))

  # keep waiting for the download order to come online
  # with status code 303. 202 = connection accepted, but job queued.
  # http error codes (>400) will be trapped by the wf_transfer()
  # function call
  while (ct$code == 202) {
    # check formatting state variable CDS

    # exit routine when the time out
    if (Sys.time() > time_out) {
      if (verbose) {
        message("  Your download timed out, however ...\n")
        exit_message(
          url = switch(service,
                       "cds" = ct$request_id,
                       "ads" = ct$request_id,
                       "webapi" = ct$href),
          path = path,
          file = request$target,
          service = service
        )
      }
      return(ct)
    }

    # set retry rate, dynamic for WebAPI, static 10 seconds CDS
    retry <- as.numeric(ifelse((service == "cds" | service == "ads"),
                               5, ct$retry))

    if (verbose) {
      # let a spinner spin for "retry" seconds
      spinner(retry)
    } else {
      # sleep
      Sys.sleep(retry)
    }

    # attempt a download. Use 'input_user', can also
    # be NULL (load user information from '.ecmwfapirc'
    # file inside wf_transfer).
    ct <- wf_transfer(
      url = switch(service,
                   "cds" = ct$request_id,
                   "ads" = ct$request_id,
                   "webapi" = ct$href),
      user    = user,
      service  = service,
      filename = tmp_file,
      verbose  = verbose
    )
  }

  # Copy data from temporary file to final location
  # and delete original, with an exception for tempdir() location.
  # The latter to facilitate package integration.
  if (path != tempdir()) {
    src <- file.path(tempdir(), tmp_file)
    dst <- file.path(path, request$target)

    # rename / move file
    move <- suppressWarnings(file.rename(src, dst))

    # check if the move was succesful
    # fails for separate disks/partitions
    # then copy and remove
    if (!move) {
      file.copy(src, dst, overwrite = TRUE)
      file.remove(src)
    }

    if (verbose) {
      message(sprintf("- moved temporary file to -> %s", dst))
    }

  } else {
    dst <- file.path(path, tmp_file)
    message("- file not copied and removed (path == tempdir())")
  }

  # delete the request upon succesful download
  # to free up other download slots. Not possible
  # for ECMWF mars requests (skip)
  if (!request$dataset == "mars") {
    wf_delete(
      user   = user,
      url = switch(service,
                   "cds" = ct$request_id,
                   "ads" = ct$request_id,
                   "webapi" = ct$href),
      verbose = verbose,
      service = service
    )
  }

  # return final file name/path (dst = destination).
  return(invisible(dst))
}
