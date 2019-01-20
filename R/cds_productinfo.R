#' CDS product list for a given dataset
#'
#' Shows and returns detailed product information about a specific data set
#' (see \code{\link[ecmwfr]{cds_datasets}}).
#'
#' @param user string, user ID used to sign up for the CDS data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{cds_set_key}}.
#' Note: can also be set to \code{NULL}, in this case user and key will
#' be read from the \code{.cdsapirc} file (located in your home folder).
#' @param show boolean, default \code{TRUE}. If \code{TRUE} the description
#' will be shown in your browser.
#' @param verbose boolean, default \code{FALSE}.
#' @return invisible return of the list as retrieved from the CDS server.
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{cds_datasets}}.
#' @export
#' @author Reto Stauffer

cds_productinfo <- function(user, dataset, show = TRUE, verbose = FALSE) {

  # Keep input 'user' for later!
  input_user <- user

  # check the login credentials
  if(missing(user)){
    stop("Please provide CDS user ID (or set user = NULL, see manual)")
  } else if(is.null(user)) {
      tmp  <- ecmwfr::cds_key_from_file(verbose = verbose)
      user <- tmp$user; key <- tmp$key; rm(tmp)
  } else {
    # get key from uername
    key <- cds_get_key(user)
  }

  # Get list of data sets to which the user can choose from.
  # Check if input 'dataset' is a valid choice.
  ds <- ecmwfr::cds_datasets(user = input_user)
  dataset <- match.arg(dataset, ds$name)

  # query the status url provided
  response <- httr::GET(sprintf("%s/resources/%s", cds_server(), dataset))

  # trap errors
  if (httr::http_error(response)){
    stop("Your request failed", call. = FALSE)
  }

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  # Write temporary html file
  if(show) {
    tmp_file <- tempfile("emcwfr_info_", fileext = ".html")
    write(file = tmp_file, "<!DOCTYPE html>
          <html>
          <head>
          <style>
             body { font-family: arial, sans-serif; }
          </style>
          </head>
          <body>")
    for(n in names(ct))
        write(file = tmp_file, sprintf("<h2>%s</h2>%s", n, ct[[n]]), append = TRUE)
    write(file = tmp_file, "\n</body>\n</html>\n", append = TRUE)
    # Open in browser
    browseURL(tmp_file)
  }

  # return content
  invisible(ct)
}




