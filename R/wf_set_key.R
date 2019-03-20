#' Set secret ECMWF token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' @param user user (email address) used to sign up for the ECMWF data service
#' @param key token provided by ECMWF
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{wf_get_key}}
#' @export
#' @author Koen Kufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(user = "test@mail.com")
#'}

wf_set_key <- function(user, key, service = "webapi"){
  keyring::key_set_with_value(make_key_service(service), user, password = key)
}

make_key_service <- function(service) {
  paste("ecmwfr", service, sep = "_")
}
