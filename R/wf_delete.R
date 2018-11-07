#' ECMWF delete request
#'
#' Deletes a staged download from the queue
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param url url to query
#' @param verbose show feedback on processing
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @examples
#'
#' \donttest{
#' # set key
#' wf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(email = "test@mail.com")
#'}

wf_delete <- function(
  email,
  url,
  verbose = TRUE
){

  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  key <- wf_get_key(email)

  # remove a queued download
  response <- httr::DELETE(
    url,
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key)
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
