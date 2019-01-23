#' Get secret ECMWF token
#'
#' Returns you token set by \code{\link[ecmwfr]{wf_set_key}}
#'
#' @param email email address used to sign up for the ECMWF data service
#' @param service which service to use
#' @return the key set using \code{\link[ecmwfr]{wf_set_key}} saved
#' in the keychain
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' @export
#' @author Koen Kufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(email = "test@mail.com")
#'}

wf_get_key <- function(email, service = "webapi"){
  if(tolower(service) == "webapi"){
    keyring::key_get(service = "ecmwfr_webapi",
                     username = email)
  }else{
    keyring::key_get(service = "ecmwfr_cds",
                     username = email)
  }
}
