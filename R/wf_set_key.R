#' Set secret ECMWF token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' @param user user (email address) used to sign up for the ECMWF data service
#' @param key token provided by ECMWF
#'
#' @details
#' If either `user` or `key` are `NULL`, `wf_set_key()` will open a browser
#' to the URL where you can get an API key and will save them interactivelly.
#'
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

wf_set_key <- function(user = NULL, key = NULL){
  if(is.null(user) | is.null(key)) {
    if (!interactive()) {
      stop("wf_set_key needs to be run interactivelly if `user` or `key` are NULL")
    }
    browseURL("https://api.ecmwf.int/v1/key/")
    message("Login or register to get a key")
    user <- readline("Email: ")

    if (nchar(user) == 0) {
      stop("Invalid user")
    }

    key <- readline("API key: ")

    if (nchar(user) != 32) {
      stop("Invalid key")
    }
  }

  keyring::key_set_with_value("ecmwfr", user, password = key)
}

