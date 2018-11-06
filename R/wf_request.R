#' ECMWF data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}. The function only
#' allows NetCDF downloads, and will override calls for grib data.
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default = Inf)
#' @param transfer logical, download data TRUE or FALSE (default = FALSE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF API page
#' @param verbose show feedback on processing
#' @return a download query staging url or a netCDF of data on disk
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_status}}
#' @export
#' @examples
#'
#' \donttest{
#' # set key
#' wf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(email = "test@mail.com")
#'}

wf_request <- function(
  email,
  path = tempdir(),
  time_out = Inf,
  transfer = FALSE,
  request = list(stream = "oper",
                 levtype = "sfc",
                 param = "165.128/166.128/167.128",
                 dataset = "interim",
                 step = "0",
                 grid = "0.75/0.75",
                 time = "00",
                 date = "2014-07-01/to/2014-07-02",
                 type = "an",
                 class = "ei",
                 area = "50/10/51/11",
                 format = "netcdf",
                 target = "tmp.nc"),
  verbose = TRUE
  ){

  # check the login credentials
  if(missing(email)){
    stop("Please provide ECMWF login credentials and data request!")
  }

  # get key from email
  key <- wf_get_key(email)

  # force the use of netcdf
  request$format <- "netcdf"
  request$target <- paste0(tools::file_path_sans_ext(request$target),
                           ".nc")

  # get the response from the query provided
  response <- httr::POST(
    paste(ecmwf_server(),
          "datasets",
          request$dataset,
          "requests", sep = "/"),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key),
    body = request,
    encode = "json"
    )

  # trap general http error
  if(httr::http_error(response)){
    stop("Your request was malformed, check your request statement",
         call. = FALSE)
  }

  # grab content, to look at the status
  ct <- httr::content(response)

  # some verbose feedback
  if(verbose){
    message("Your data request will be served at url endpoint:")
    message(ct$href)
  }

  # only return the content of the query
  if(!transfer){
    return(ct)
  }

  # start time-out counter
  time_out_start <- Sys.time()

  # keep waiting for the download order to come online
  # with status code 303
  while(ct$code == 202){

    if(verbose){
      # let a spinner spin for "retry" seconds
      spinner(as.numeric(ct$retry))
    } else {
      # sleep
      Sys.sleep(ct$retry)
    }

    # check the status of the download, no download
    ct <- wf_status(email = email, url = ct$href)
  }

  print("bla")

  # if the http code is 303 (a redirect)
  # follow this query and download the data
  if(ct$code == 303){
    wf_transfer(email = email,
                url = ct$href,
                verbose = verbose)
  }

  # Copy data from temporary file to final location
  # and delete original, with an exception for tempdir() location.
  # The latter to facilitate package integration.
  if (path != tempdir()) {

    # create temporary output file
    ecmwf_tmp_file <- file.path(tempdir(), "ecmwf_tmp.nc")

    # copy temporary file to final destination
    file.copy(ecmwf_tmp_file,
              file.path(path, request$target),
              overwrite = TRUE,
              copy.mode = FALSE)

    # cleanup of temporary file
    invisible(file.remove(ecmwf_tmp_file))
  } else {
    message("Output path == tempdir(), file not copied and removed!")
  }

  # delete the request upon succesful download
  wf_delete(email = email,
            url = ct$href,
            verbose = verbose)
}
