#' Renders product lists for a given dataset and data service
#'
#' Shows and returns detailed product information about a specific data set
#' (see \code{\link[ecmwfr]{wf_datasets}}).
#'
#' @param user string, user ID used to sign up for the CDS / ADS data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}.
#' @param dataset character, name of the data set for which the product
#' information should be loaded.
#' @param service which service to use, one of \code{webapi}, \code{cds}
#' or \code{ads} (default = webapi)
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
  service = "cds",
  simplify = TRUE
  ){

  # check the login credentials
  if(missing(user) || missing(dataset)){
    stop("Please provide a user ID")
  }

  # match arguments, if not stop
  service <- match.arg(service, c("cds", "ads"))

  if (service == "cds" || service == "ads"){
  response <- httr::GET(
      sprintf(
        "%s/resources/%s",
        wf_server(service = service),
        dataset
        )
    )
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
