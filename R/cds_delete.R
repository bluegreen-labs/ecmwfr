#' CDS delete request
#'
#' Deletes a staged download from the queue
#'
#' @param user character, user ID to sign up for the CDS data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{cds_set_key}}.
#' Can also be \code{NULL} if you preferr to use the \code{.cdsapirc} file.
#' @param url task url for request
#' @param verbose show feedback on processing
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{cds_set_key}}
#' \code{\link[ecmwfr]{cds_transfer}}
#' \code{\link[ecmwfr]{cds_request}}
#' @author Reto Stauffer

cds_delete <- function(user, url, verbose = TRUE){

  # check the login credentials
  if(missing(user) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key
  if(is.null(user)) {
    tmp <- cds_key_from_file(verbose = verbose)
    user <- tmp$user; key <- tmp$key; rm(tmp)
  } else {
    key <- cds_get_key(user)
  }

  # remove a queued download
  # get the response from the query provided
  response <- httr::DELETE(
    url,
    httr::authenticate(user, key),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json")
  )

  # check purging of request
  if(response$status == 204){
    if (verbose){
      message("- request purged from queue!")
    } else {
      invisible()
    }
  } else {
    warning("Request not purged from queue, check download!")
  }
}
