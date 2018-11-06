#' ECMWF download request
#'
#' Returns the contents of the requested url as a netCDF file downloaded
#' to disk.
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{ecmwf_set_key}}
#' @param url url to query
#' @param path path were to store the downloaded data
#' @param filename filename to use for the downloaded data
#' @return a netCDF of data on disk as specified by a
#' \code{\link[ecmwfr]{ecmwf_request}}
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{ecmwf_set_key}}
#' \code{\link[ecmwfr]{ecmwf_download}}
#' \code{\link[ecmwfr]{ecmwf_request}}
#' @export
#' @examples
#'
#' \donttest{
#' # set key
#' ecmwf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' ecmwf_get_key(email = "test@mail.com")
#'}


ecmwf_download <- function(
  email,
  url,
  path = tempdir(),
  filename = "ecmwf_tmp.nc"
){

  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  key <- ecmwf_get_key(email)

  # create temporary output file
  ecmwf_tmp_files <- file.path(tempdir(), filename)

  # provide some feedback on the url which is
  # downloaded
  message("Downloading request at:")
  message(ct$href)

  # submit download query
  response <- httr::GET(
    url,
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key),
    httr::progress(),
    encode = "json",
    httr::write_disk(path = ecmwf_tmp_file, overwrite = TRUE)
  )

  # trap errors on download, return a general error statement
  if (httr::http_error(response)){
    stop("Your requested download failed", call. = FALSE)
  }
}
