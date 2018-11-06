#' ECMWF status request
#'
#' Returns the contents of a request url, useful when checking staged
#' downloads which were not directly downloaded by ecmwf_download.
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{ecmwf_set_key}}
#' @param url url to query
#' @return returns a nested list of download information
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

ecmwf_status <- function(
  email,
  url
){

  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  key <- ecmwf_get_key(email)

  # query the status url provided
  response <- httr::GET(
    url,
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key),
    encode = "json"
  )

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  # return content in full
  return(ct)
}
