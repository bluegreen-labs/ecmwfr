#' ECMWF data transfer function
#'
#' Returns the contents of the requested url as a (NetCDF) file downloaded
#' to disk or the current status of the requested transfer.
#'
#' Normal workflows would use the methods included in returned objects. This is
#' for legacy support and custom scripting only.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}.
#' @param url R6 \code{\link[ecmwfr]{wf_request}}) query output or API endpoint
#' @param path path were to store the downloaded data
#' @param filename filename to use for the downloaded data
#' @param verbose show feedback on data transfers
#' @return a (netCDF) file of data on disk as specified by a
#' \code{\link[ecmwfr]{wf_request}}
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # request data and grab url and try a transfer
#' # (request not provided)
#' r <- wf_request(request, transfer = FALSE)
#'
#' # check transfer, will download if available
#' wf_transfer(r$get_url())
#'}

wf_transfer <- function(
    url,
    user = "ecmwfr",
    path = tempdir(),
    filename = tempfile("ecmwfr_", tmpdir = ""),
    verbose = TRUE
    ) {

  if (inherits(url, "ecmwfr_service")) {
    url$transfer()
    return(url)
  }

  # get key
  key <- wf_get_key(
    user = user
  )

  # fetch download location from results URL
  # this is now a two step process
  response <- httr::GET(
    file.path(url, "results"),
    httr::add_headers(
      "PRIVATE-TOKEN" = key
    )
  )

  # trap general http error
  if (httr::http_error(response)) {
    stop("Your requested file is unavailable - check url", call. = FALSE)
  }

  # grab content
  ct <- httr::content(response)

  # return the asset location
  file_url <- ct$asset$value$href

  # create (temporary) output file
  tmp_file <- file.path(path, filename)

  # download file
  response <-  httr::GET(
    file_url,
    httr::write_disk(tmp_file, overwrite = TRUE),
    httr::progress()
  )

  # trap general http error
  if (httr::http_error(response)) {
    stop("Your requested download failed - check url", call. = FALSE)
  }

  if(verbose){
    message("File succesfully downloaded! ")
  }

  # return state variable
  return(invisible(ct))
}
