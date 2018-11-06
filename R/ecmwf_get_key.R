#' Get secret ECMWF token
#'
#' Returns you token set by ecmwf_set_key()
#'
#' @param email email address used to sign up for the ECMWF data service
#' @return the key set using ecmwf_set_key() saved in the keychain
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{ecmwf_set_key}}
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

ecmwf_get_key <- function(email){
  keyring::key_get(service = "ecmwfr",
                   username = email)
}
