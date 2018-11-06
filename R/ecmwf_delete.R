#' ECMWF delete request
#'
#' Deletes a staged download from the queue
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{ecmwf_set_key}}
#' @param url url to query
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{ecmwf_set_key}}
#' \code{\link[ecmwfr]{ecmwf_download}}
#' \code{\link[ecmwfr]{ecmwf_request}}
#' @export
#' @examples
#'
#' \donttest{
#' # set key
#' ecmwf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' ecmwf_get_key(email = "test@mail.com")
#'}


ecmwf_delete <- function(
  email,
  url
){

  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  key <- ecmwf_get_key(email)

  # Finally when all went well we have to remove the subset
  # from the queued list so that memory is de-allocated on the
  # ECMWF server!
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
    message("Request purged from queue!")
  } else {
    warning("Request not purged from queue, check download!")
  }
}
