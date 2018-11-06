#' ECMWF data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start
#' @param transfer logical, download data TRUE or FALSE (default = FALSE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF API page
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
  time_out = 3600,
  transfer = FALSE,
  request = list(stream = "oper",
                 levtype = "sfc",
                 param = "165.128/166.128/167.128",
                 dataset = "interim",
                 step = "0",
                 grid = "0.75/0.75",
                 time = "00/06/12/18",
                 date = "2014-07-01/to/2014-07-31",
                 type = "an",
                 class = "ei",
                 area = "73.5/-27/33/45",
                 format = "netcdf",
                 target = "tmp.nc")){

  # check the login credentials
  if(missing(email)){
    stop("Please provide ECMWF login credentials and data request!")
  }

  # get key from email
  key <- wf_get_key(email)

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

  # line to trap general httr error (server not reachable etc.)

  # grab content, to look at the status
  ct <- httr::content(response)

  # if the status code is >= 400 stop
  if(ct$code >= 400){
    stop("Your request was malformed, check your request statement",
         call. = FALSE)
  }

  # only return the content of the query
  if(!transfer){
    return(ct)
  }

  # set spinner count for some feedback
  # downloads can take a while it seems
  spinner_count <- 1

  # start time-out counter
  time_out_start <- Sys.time()

  # keep waiting for the download order to come online
  # with status code 303
  while(ct$code == 202){

    # update spinner count
    spinner_count <- ifelse(spinner_count < 4, spinner_count + 1, 1)

    # update spinner message
    message(paste0(c("-","\\","|","/")[spinner_count],
                   " Your request is ",
                   ct$status,
                   ", waiting on server response...\r"), appendLF = FALSE)

    # sleep for the time (in seconds) provided
    # in the content returned upon query
    Sys.sleep(ct$retry)

    # check the status of the download, no download
    ct <- wf_status(email = email, url = ct$href)
  }

  # if the http code is 303 (a redirect)
  # follow this query and download the data
  if(ct$code == 303){
    wf_transfer(email = email)
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
  wf_delete(email = email, url = ct$href)
}
