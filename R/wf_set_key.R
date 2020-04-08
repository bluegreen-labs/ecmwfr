#' Set secret ECMWF token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' @param user user (email address) used to sign up for the ECMWF data service
#' @param key token provided by ECMWF
#' @param service service associated with credentials ("webapi" or "cds")
#'
#' @return It invisibly returns the user.
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
#'
#' # leave user and key empty to open a browser window to the service's website
#' # and type the key interactively
#' wf_get_key()
#'
#'}
#' @importFrom utils browseURL
wf_set_key <- function(user, key, service) {
  if (keyring::default_backend()$name != "env") {
    if (keyring::keyring_is_locked()) {
      message("Your keyring is locked please
              unlock with your keyring password!")
      keyring::keyring_unlock()
    }
  }

  if (missing(service)) {
    stop("Please provide a service for which
         to set your API key ('webapi' or 'cds')")
  }

  if (missing(user) | missing(key)) {
    if (!interactive()) {
      stop("wf_set_key needs to be run interactivelly if `user` or `key` are
           not provided.")
    }
    browseURL(wf_key_page(service))
    message("Login or register to get a key")
    user <- readline("User ID / email: ")
    key <- getPass::getPass(msg = "API key: ")
    if (is.null(key))
      stop("No key supplied.")
  }

  # check login
  login_ok <- wf_check_login(user = user,
                             key = key,
                             service = service)

  if (!login_ok) {
    stop("Could not validate login information.")
  } else {
    keyring::key_set_with_value(
      service = make_key_service(service),
      username = user,
      password = key
    )
    message("User ", user, " for ", service, " service added successfully")
    return(invisible(user))
  }

}
