#' ECMWF data transfer function
#'
#' Returns the contents of the requested url as a netCDF file downloaded
#' to disk or the current status of the requested transfer.
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
  type,
  path = tempdir(),
  filename = "ecmwf_tmp.nc",
  verbose = TRUE
){

  # wf_transfer is used for both, ecmwf and cds data transfer.
  # To get correct email/key or user/key we need the type argument.
  type <- match.arg(type, c("ecmwf", "cds"))
  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  if(type == "cds") {
    if(is.null(email)) {
      tmp   <- cds_key_from_file(verbose = verbose)
      email <- tmp$user; key <- tmp$key; rm(tmp)
    } else {
      key <- cds_get_key(email)
    }
  } else {
    if(is.null(email)) {
      tmp   <- wf_key_from_file(verbose = verbose)
      email <- tmp$user; key <- tmp$key; rm(tmp)
    } else {
      key <- wf_get_key(email)
    }
  }

  # create temporary output file
  ecmwf_tmp_file <- file.path(path, filename)

  # download query
  response <- httr::GET(
    url,
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key),
    encode = "json"
  )

  # trap errors on download, return a general error statement
  if (httr::http_error(response)){
    stop("Your requested download failed - check url", call. = FALSE)
  }

  # check the content, and status of the download
  # will fail on large (binary) files
  ct <- httr::content(response)

  # write raw data to file from memory
  # if not return url + passing code
  if (class(ct) == "raw"){

    if(verbose){
      message("- polling server for a data transfer")
      message("- writing file to disk              ")
    }

    # write binary file
    f <- file(ecmwf_tmp_file, "wb")
    writeBin(ct, f)
    close(f)

    # return element to exit while loop, including
    # the url to close the connection
    return(data.frame(code = "downloaded",
                      href = url,
                      stringsAsFactors = FALSE))
  } else {
   return(ct)
  }
}
