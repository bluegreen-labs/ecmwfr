#' ECMWF data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}. The function only
#' allows NetCDF downloads, and will override calls for grib data.
#' Note that the function will do some basic checks on the \code{request} input
#' to identify possible problems.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default =
#' \code{3*3600} seconds).
#' @param transfer logical, download data TRUE or FALSE (default = FALSE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF API page
#' @param verbose show feedback on processing
#' @return a download query staging url or (invisible) filename of the NetCDF
#' file on your local disc
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' @export
#' @author Koen Kufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' request <-  = list(stream = "oper",
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
#' # get the default test data
#' wf_request(user = "test@mail.com", request = request)
#'}

wf_request <- function(
  email,
  service = "webapi",
  request,
  transfer = FALSE,
  path = tempdir(),
  time_out = 3*3600,
  verbose = TRUE
  ){

  # match arguments, if not stop
  service <- match.arg(service, c("webapi", "cds"))

  # check the login credentials
  if(missing(email) || missing(request)){
    stop("Please provide ECMWF or CDS login credentials and data request!")
  }

  # get key
  key <- wf_get_key(user, service = service)

  # getting api url: different handling if 'dataset = "mars"',
  # requests to 'dataset = "mars"' require a non-public user
  # account (member states/commercial).
  url <- if(request$dataset == "mars") {
    sprintf("%s/services/mars/requests", wf_server())
  } else{
    sprintf("%s/datasets/%s/requests", wf_server(), request$dataset)
  }

  # depending on the service get the response
  # for the query provided
  if (service == "webapi"){
    response <- httr::POST(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = user,
        "X-ECMWF-KEY" = key),
      body = request,
      encode = "json"
      )
  } else {
    response <- httr::POST(
      sprintf("%s/resources/%s", wf_server(service = "cds"),
              request$dataset),
      httr::authenticate(user, key),
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json"),
      body = request,
      encode = "json"
    )
  }

  # trap general http error
  if(httr::http_error(response)){
    stop(httr::content(response),
         call. = FALSE)
  }

  # grab content, to look at the status
  ct <- httr::content(response)

  # some verbose feedback
  if(verbose){
    message("- staging data transfer at url endpoint:")
    message("  ", ct$href)
  }

  # on exit show message
  on.exit(
    exit_message(
      id = ct$request_id,
      path = path,
      file = request$target)
    )

  # only return the content of the query
  if(!transfer){
    return(ct)
  }

  # set time-out counter
  if(verbose) message(sprintf("- timeout set to %.1f hours", time_out/3600))

  # set time-out
  time_out <- Sys.time() + time_out

  # Temporary file name, will be used in combination with tempdir() when
  # calling wf_transfer. The final file will be moved to the user-defined
  # 'path' as soon as the download has been finished.
  tmp_file <- basename(tempfile("ecmwfr_"))

  # keep waiting for the download order to come online
  # with status code 303. 202 = connection accepted, but job queued.
  # http error codes (>400) will be trapped by the wf_transfer()
  # function call
  while(ct$code == 202){

    # exit routine when the time out
    if(Sys.time() > time_out){
      if(verbose){
        # Waiting for request to be finished timed out.
        message("  Please use the ECMWF or CDS job list to track your jobs at:")
        message("  https://apps.ecmwf.int/webmars/joblist/ or")
        message("  https://cds.climate.copernicus.eu/cdsapp#!/yourrequests")
        message("  and retry download using wf_transfer().")
        message("  Note that there are user-dependent limits of submitted jobs.")
        message("  Delete the job using wf_delete() upon completion!")
      }
      return(ct)
    }

    if(verbose){
      # let a spinner spin for "retry" seconds
      spinner(as.numeric(ct$retry))
    } else {
      # sleep
      Sys.sleep(ct$retry)
    }

    # attempt a download. Use 'input_user', can also
    # be NULL (load user information from '.ecmwfapirc'
    # file inside wf_transfer).
    ct <- wf_transfer(user    = user,
                      url      = ct$href,
                      service  = "webapi",
                      filename = tmp_file,
                      verbose  = verbose)
  }

  # Copy data from temporary file to final location
  # and delete original, with an exception for tempdir() location.
  # The latter to facilitate package integration.
  if (path != tempdir()) {

    src <- file.path(tempdir(), tmp_file)
    dst <- file.path(path, request$target)

    if ( verbose ){
      message(sprintf("- moved temporary file to -> %s", dst))
    }

    # rename / move file
    file.rename(src, dst)

  } else {
    dst <- file.path(path, tmp_file)
    message("- file not copied and removed (path == tempdir())")
  }

  # delete the request upon succesful download
  # to free up other download slots. Not possible
  # for ECMWF mars requests (skip)
  if(!request$dataset == "mars") {
    wf_delete(user   = user,
              url     = ct$href,
              verbose = verbose)
  }

  # return final file name/path (dst = destination).
  return(invisible(dst))
}
