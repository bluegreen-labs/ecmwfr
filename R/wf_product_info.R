#' Renders product lists for a given dataset and data service
#'
#' Shows and returns detailed product information about a specific data set
#' (see \code{\link[ecmwfr]{wf_datasets}}).
#'
#' @param user string, user ID used to sign up for the CDS data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}.
#' @param dataset character, name of the data set for which the product
#' information should be loaded.
#' @param service which service to use, one of \code{webapi} or \code{cds}
#' @param simplify boolean, default \code{TRUE}. If \code{TRUE} the description
#' will be returned as tidy data instead of a nested list.
#'
#' @return Downloads a tidy data frame with product descriptions from CDS. If
#' \code{simplify = FALSE} a list with product details will be returned.
#'
#' @examples
#' \dontrun{
#'    # Open description in browser
#'    wf_product_info(NULL, "reanalysis-era5-single-levels")
#'
#'    # Return information
#'    info <- wf_product_info(NULL,
#'     "reanalysis-era5-single-levels", show = FALSE)
#'    names(info)
#' }
#' @seealso \code{\link[ecmwfr]{wf_datasets}}.
#' @export
#' @author Reto Stauffer, Koen Hufkens

wf_product_info <- function(
  dataset,
  user,
  service = "webapi",
  simplify = TRUE
  ){

  # check the login credentials
  if(missing(user) || missing(dataset)){
    stop("Please provide CDS user ID (or set user = NULL, see manual)")
  }

  # match arguments, if not stop
  service <- match.arg(service, c("webapi", "cds"))

  # query the status url provided
  if (service == "webapi"){

    # get webapi key
    key <- wf_get_key(user = user, service = service)

    # Get list of data sets to which the user can choose from.
    # Check if input 'dataset' is a valid choice.
    ds <- wf_datasets(user = user, service = service)
    dataset <- match.arg(dataset, ds$name)

    response <- httr::GET(
      paste0(wf_server(),"/datasets/",dataset),
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = user,
        "X-ECMWF-KEY" = key),
      encode = "json")

  } else {
    response <- httr::GET(sprintf("%s/resources/%s",
                                  wf_server(service = "cds"),
                                  dataset))
  }

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
    # use xml2 or rvest to mangle html abstracts etc. who the hell serves
    # up html anyway?
    return(ct)
  }

  # return content
  return(ct)
}
