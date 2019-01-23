#' CDS product list for a given dataset
#'
#' Shows and returns detailed product information about a specific data set
#' (see \code{\link[ecmwfr]{cds_datasets}}).
#'
#' @param user string, user ID used to sign up for the CDS data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{cds_set_key}}.
#' Note: can also be set to \code{NULL}, in this case user and key will
#' be read from the \code{.cdsapirc} file (located in your home folder).
#' @param dataset character, name of the data set for which the product
#' information should be loaded.
#' @param show boolean, default \code{TRUE}. If \code{TRUE} the description
#' will be shown in your browser.
#' @param verbose boolean, default \code{FALSE}.
#'
#' @return Downloads a (html) product description from CDS. If
#' \code{show = FALSE} a list with product details will be returned.
#' If \code{show = TRUE} the product information will be shown in a local
#' browser window (plus invisible return of the details as if \code{show}
#' whould be set \code{FALSE}).
#'
#' @examples
#' \donttest{
#'    # Opend description in browser
#'    cds_productinfo(NULL, "reanalysis-era5-single-levels")
#'
#'    # Return information
#'    info <- cds_productinfo(NULL, "reanalysis-era5-single-levels", show = FALSE)
#'    names(info)
#' }
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{cds_datasets}}.
#' @export
#' @author Reto Stauffer

wf_product_info <- function(
  user,
  dataset,
  show = TRUE,
  verbose = FALSE
  ){

  # check the login credentials
  if(missing(user))
    stop("Please provide CDS user ID (or set user = NULL, see manual)")

  # get key
  key <- wf_get_key(email, service = "cds")

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
    utils::browseURL(tmp_file)
  }

  # return content
  invisible(ct)
}




