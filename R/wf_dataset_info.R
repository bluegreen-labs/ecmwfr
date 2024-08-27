#' List ECMWF Data Store dataset information
#'
#' Shows and returns detailed product information about a specific data set
#' (see \code{\link[ecmwfr]{wf_datasets}}). This includes the list of
#' sub-products in the collection as well as date and time ranges.
#'
#' @param dataset character, name of the data set for which the product
#' information should be loaded
#' @param simplify boolean, default \code{TRUE}. If \code{TRUE} the description
#' will be returned as tidy data instead of a nested list.
#'
#' @return Downloads a tidy data frame with product descriptions from CDS. If
#' \code{simplify = FALSE} a list with product details will be returned.
#'
#' @examples
#' \dontrun{
#'  # Return information
#'  info <- wf_dataset_info("reanalysis-era5-single-levels")
#'  names(info)
#' }
#' @seealso \code{\link[ecmwfr]{wf_datasets}}.
#' @export
#' @author Reto Stauffer, Koen Hufkens

wf_dataset_info <- function(
  dataset,
  simplify = TRUE
  ){

  # load available datasets
  datasets <- wf_datasets()

  if(dataset %in% datasets$name){

    # split out the service
    url <-datasets$url[which(dataset == datasets$name)]

    # API call to get product info
    response <- httr::GET(
      url
    )

    # trap errors
    if (httr::http_error(response)){
      stop("Your request failed", call. = FALSE)
    }

    # check the content, and status of the
    # download
    ct <- httr::content(response)

  } else {
    stop("Your requested dataset does not exist!")
  }


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
