#' ECMWF data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[ecmwfr]{wf_transfer}}. The function only
#' allows NetCDF downloads, and will override calls for grib data.
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' Can also be set to \code{NULL}, in this case email and key will be loaded
#' from the \code{.ecmwfapirc} file (located in your home folder).
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default = 3600)
#' @param transfer logical, download data TRUE or FALSE (default = FALSE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF API page
#' @param verbose show feedback on processing
#' @return a download query staging url or a netCDF of data on disk
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' @export
#' @author Koen Kufkens
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
                 param = "167.128",
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

  # We need to keep the original email for later!
  input_email <- email
  # get key from email
  if(is.null(email)) {
    tmp   <- wf_key_from_file(verbose)
    email <- tmp$email; key <- tmp$key; rm(tmp)
  } else {
    key <- wf_get_key(email)
  }

  # force the use of netcdf
  request$format <- "netcdf"
  request$target <- paste0(tools::file_path_sans_ext(request$target),
                           ".nc")
  # getting api url: different handling if 'dataset = "mars"',
  # requests to 'dataset = "mars"' require a non-public user
  # account (member states/commercial).
  url <- if(request$dataset == "mars") {
    sprintf("%s/services/mars/requests", ecmwf_server())
  } else{
    sprintf("%s/datasets/%s/requests", ecmwf_server(), request$dataset)
  }

  # get the response from the query provided
  response <- httr::POST(
    url,
    #paste(ecmwf_server(),
    #      "datasets",
    #      request$dataset,
    #      "requests", sep = "/"),
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
    stop(httr::content(response),
         call. = FALSE)
  }

  # grab content, to look at the status
  ct <- httr::content(response)

  # some verbose feedback
  if(verbose){
    message("Staging data transfer at url endpoint:")
    message(ct$href)
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

  # keep waiting for the download order to come online
  # with status code 303
  while(ct$code == 202){

    # exit routine when the time out
    # is reached, create message to consult
    # the ecmwf website to download the data
    # or retain the download url and use
    # wf_transfer()
    if(Sys.time() > time_out){
      message("Please use the MARS job list to track your jobs at:")
      message("https://apps.ecmwf.int/webmars/joblist/")
      message("and retry download using wf_transfer() for url:")
      message(ct$href)
      message("There is a limit of 3 active and 20 queued jobs.")
      message("Delete the job using wf_delete() upon completion!")
      return(ct)
    }

    if(verbose){
      # let a spinner spin for "retry" seconds
      spinner(as.numeric(ct$retry))
    } else {
      # sleep
      Sys.sleep(ct$retry)
    }

    # attempt a download
    ct <- wf_transfer(email    = input_email,
                      url      = ct$href,
                      type     = "ecmwf",
                      filename = tmp_file,
                      verbose  = verbose)
  }

  # Copy data from temporary file to final location
  # and delete original, with an exception for tempdir() location.
  # The latter to facilitate package integration.
  if (path != tempdir()) {
    # copy temporary file to final destination
    src <- file.path(tempdir(), tmp_file)
    dst <- file.path(path, request$target)
    if ( verbose ) cat(sprintf("- move file: %s -> %s\n", src, dst))
    file.rename(src, dst)
  } else {
    dst <- file.path(path, tmp_file)
    message("- file not copied and removed (path == tempdir())")
  }

  # delete the request upon succesful download
  # to free up other download slots
  wf_delete(email = input_email,
            url = ct$href,
            verbose = verbose)

  # return final file name/path
  return(dst)
}
