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
#' @param simplify boolean, default \code{TRUE}. If \code{TRUE} the description
#' will be returned as tidy data instead of a nested list.
#' @param verbose boolean, default \code{FALSE}.
#'
#' @return Downloads a tidy data frame with product descriptions from CDS. If
#' \code{simplify = FALSE} a list with product details will be returned.
#'
#' @examples
#' \donttest{
#'    # Opend description in browser
#'    wf_product_info(NULL, "reanalysis-era5-single-levels")
#'
#'    # Return information
#'    info <- wf_product_info(NULL,
#'     "reanalysis-era5-single-levels", show = FALSE)
#'    names(info)
#' }
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{cds_datasets}}.
#' @export
#' @author Reto Stauffer

wf_product_info <- function(
  user,
  dataset,
  simplify = TRUE,
  verbose = FALSE
  ){

  # check the login credentials
  if(missing(user) || missing(dataset)){
    stop("Please provide CDS user ID (or set user = NULL, see manual)")
  }

  # get key
  key <- wf_get_key(user, service = "cds")

  # Get list of data sets to which the user can choose from.
  # Check if input 'dataset' is a valid choice.
  ds <- wf_datasets(user = user, service = "cds")
  dataset <- match.arg(dataset, ds$name)

  # query the status url provided
  response <- httr::GET(sprintf("%s/resources/%s", wf_server(service = "cds"),
                                dataset))

  # trap errors
  if (httr::http_error(response)){
    stop("Your request failed", call. = FALSE)
  }

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  # Write temporary html file
  if(simplify){
    # TODO:
    # instead of html which is useless for processing and documentation
    # (only a visual aid) return a tidy data frame (instead of a list)
    # with data which is easily machine readable
    return(ct)
  }

  # return content
  return(ct)
}
