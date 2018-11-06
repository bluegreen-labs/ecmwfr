#' Set secret ECMWF token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' @param email email address used to sign up for the ECMWF data service
#' @param key token provided by ECMWF
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{ecmwf_get_key}}
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

ecmwf_set_key <- function(email, key){
  keyring::key_set_with_value("ecmwfr",
                     email,
                     password = key)
}
