#' ECMWF data transfer function
#'
#' Returns the contents of the requested url as a netCDF file downloaded
#' to disk or the current status of the requested transfer.
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}} when
#' calling \code{\link[ecmwfr]{wf_transfer}}.
#' If set to \code{NULL} the \code{.ecmwfapirc} file will be used.
#' @param user string, user ID when calling \code{\link[ecmwfr]{cds_transfer}}.
#' If set to \code{NULL} the \code{.cdsapirc} file will be used.
#' @param url url to query
#' @param type character, one of \code{ecmwf} or \code{cds}
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

wf_transfer <- function(
  email,
  url,
  type = "ecmwf",
  path = tempdir(),
  filename = basename(tempfile("ecmwfr_", fileext = ".nc")),
  verbose = TRUE
){

  # wf_transfer is used for both, ecmwf and cds data transfer.
  # To get correct email/key or user/key we need the type argument.
  type <- match.arg(type, c("ecmwf", "cds"))
  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # If the URL is not an URL but an ID: generate URL
  if (! grepl("^https?://.*$", url)) url <- get(sprintf("%s_server", type))(url)
  if(verbose) cat(sprintf("- Downloading \"%s\"\n", url))
  
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
  tmp_file <- file.path(path, filename)

  # -----------------------
  # download requext (cds)
  if(type == "cds") {
    # Download information about request (including location)
    if(verbose) cat(sprintf("- GET: %s\n", url))
    response <- httr::GET(url,
      httr::authenticate(email, key),
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json"),
      encode = "json"
    )
    # Check if connection is a file connection
    # or a request information:
    tmp <- httr::content(response)
    if (!inherits(tmp, "raw")) {
        if(verbose) cat(sprintf("- GET: %s\n", url))
        response <- response <- httr::GET(tmp$location,
          httr::authenticate(email, key),
          httr::add_headers(
            "Accept" = "application/json",
            "Content-Type" = "application/json"),
          encode = "json"
        )
    }
  # -----------------------
  # Download request (ecmwf)
  } else {
    if(verbose) cat(sprintf("- GET: %s\n", url))
    response <- httr::GET(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = email,
        "X-ECMWF-KEY" = key),
      encode = "json"
    )
  }

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
      message(sprintf("- writing file to disk (\"%s\")", tmp_file))
    }

    # write binary file
    f <- file(tmp_file, "wb")
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

#' @rdname wf_transfer
#' @author Reto Stauffer
#' @export
cds_transfer <- function(user, ...) wf_transfer(email = user, ...)
