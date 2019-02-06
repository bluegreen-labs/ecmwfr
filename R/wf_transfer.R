#' ECMWF data transfer function
#'
#' Returns the contents of the requested url as a netCDF file downloaded
#' to disk or the current status of the requested transfer.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}.
#' @param url url to query
#' @param service which service to use, one of \code{webapi} or \code{cds}
#' @param path path were to store the downloaded data
#' @param filename filename to use for the downloaded data
#' @param verbose show feedback on data transfers
#' @param ... forwarded to \code{\link[ecmwfr]{wf_transfer}}
#' @return a netCDF of data on disk as specified by a
#' \code{\link[ecmwfr]{wf_request}}
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @author Koen Kufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' # request data and grab url and try a transfer
#' r <- wf_request("test@email.com", transfer = FALSE)
#'
#' # check transfer, will download if available
#' wf_transfer("test@email.com", url = r$href)
#'}

wf_transfer <- function(
  user,
  url,
  service = "webapi",
  path = tempdir(),
  filename = tempfile("ecmwfr_", fileext = ".nc", tmpdir = ""),
  verbose = TRUE
){

  # match arguments, if not stop
  service <- match.arg(service, c("webapi", "cds"))

  # check the login credentials
  if(missing(user) || missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # If the URL is not an URL but an ID: generate URL
  if (service == "cds") {
      url <- wf_server(id = url, service = service)
  }

  # get key
  key <- wf_get_key(user)

  # create (temporary) output file
  tmp_file <- file.path(path, filename)

  # download routine depends on service queried
  if(service == "cds") {
    response <- httr::GET(url,
      httr::authenticate(user, key),
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json"),
      encode = "json"
    )
  } else {
    response <- httr::GET(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = user,
        "X-ECMWF-KEY" = key),
      encode = "json"
    )
  }

  # trap (http) errors on download, return a general error statement
  if (httr::http_error(response)){
    stop("Your requested download failed - check url", call. = FALSE)
  }

  # check the content, and status of the download
  # will fail on large (binary) files
  ct <- httr::content(response)

  # write raw data to file from memory
  # if not returned url + passing code
  if (class(ct) == "raw" && service == "webapi"){

    if(verbose){
      message("- polling server for a data transfer")
      message(sprintf("- writing data to disk (\"%s\")", tmp_file))
    }

    # write binary file
    f <- file(tmp_file, "wb")
    writeBin(ct, f)
    close(f)

    # return data
    return(invisible(list(code = 302,
                          href = url)))
  }

  if (service == "cds"){

    # if the transfer failed, return error and stop()
    if(ct$state == "failed") {
      message("Data transfer failed!")
      stop(ct$error)
    }

    if(ct$state != "complete" || is.null(ct$state)){
      ct$code <- 202
    }

    # if completed / should not happen but still there
    if("completed" == ct$state){

      # download file
      httr::GET(ct$location,
                  httr::write_disk(tmp_file, overwrite = TRUE))

      # return exit statement
      ct$code <- 302
    }
  }

  # return state variable
  return(invisible(ct))
}
