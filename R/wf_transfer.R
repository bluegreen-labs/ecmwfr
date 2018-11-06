#' ECMWF data transfer function
#'
#' Returns the contents of the requested url as a netCDF file downloaded
#' to disk.
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param url url to query
#' @param path path were to store the downloaded data
#' @param filename filename to use for the downloaded data
#' @param verbose show feedback on data transfers
#' @return a netCDF of data on disk as specified by a
#' \code{\link[ecmwfr]{wf_request}}
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_status}}
#' \code{\link[ecmwfr]{wf_request}}
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

wf_transfer <- function(
  email,
  url,
  path = tempdir(),
  filename = "ecmwf_tmp.nc",
  verbose = TRUE
){

  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  key <- wf_get_key(email)

  # create temporary output file
  ecmwf_tmp_file <- file.path(tempdir(), filename)

  # provide some feedback on the url which is
  # downloaded
  if(verbose){
    message("Staging data transfer at url endpoint:")
    message(url)

    # submit download query
    response <- httr::GET(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = email,
        "X-ECMWF-KEY" = key),
      httr::progress(con = stderr()),
      encode = "json",
      httr::write_disk(path = ecmwf_tmp_file, overwrite = TRUE)
    )
  } else {

    # submit download query
    response <- httr::GET(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = email,
        "X-ECMWF-KEY" = key),
      encode = "json",
      httr::write_disk(path = ecmwf_tmp_file, overwrite = TRUE)
    )
  }


  # trap errors on download, return a general error statement
  if (httr::http_error(response)){
    stop("Your requested download failed", call. = FALSE)
  }
}
