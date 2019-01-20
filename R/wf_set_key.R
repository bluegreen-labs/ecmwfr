#' Set secret ECMWF token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' @param email email address used to sign up for the ECMWF data service
#' @param key token provided by ECMWF
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{wf_get_key}}
#' @export
#' @author Koen Kufkens
#' @examples
#'
#' \donttest{
#' # set key
#' wf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(email = "test@mail.com")
#'}

wf_set_key <- function(email, key){
  keyring::key_set_with_value("ecmwfr",
                     email,
                     password = key)
}

# Used to simplify the calls
ecmwf_set_key <- wf_set_key
