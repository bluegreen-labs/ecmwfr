#' Set secret ECMWF token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' In systems without keychain management set the option
#' keyring_backend to `file` (i.e. options(keyring_backend = "file"))
#' in order to write the keychain entry to an encrypted file.
#' This mostly pertains to headless Linux systems. The keychain files
#' can be found in ~/.config/r-keyring.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#'  if only a single user is needed it defaults to ("ecmwfr").
#' @param key token provided by ECMWF
#'
#' @return It invisibly returns the user.
#' @seealso \code{\link[ecmwfr]{wf_get_key}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(key = "123")
#'
#' # get key
#' wf_get_key()
#'
#' # leave user and key empty to open a browser window to the service's website
#' # and type the key interactively
#' wf_set_key()
#'
#'}
#' @importFrom utils browseURL
wf_set_key <- function(key, user = "ecmwfr") {

  # service is hard coded, but kept here should policy change
  service = "ecmwfr"

  if (keyring::default_backend()$name != "env") {
    if (keyring::default_backend()$name == "file") {
      if ("ecmwfr" %in% keyring::keyring_list()$keyring) {
        if(keyring::keyring_is_locked(keyring = "ecmwfr")){
          message("Your keyring is locked please
              unlock with your keyring password!")
          keyring::keyring_unlock(keyring = "ecmwfr")
        }
      }
    } else {
      if (keyring::keyring_is_locked()) {
        message("Your keyring is locked please
              unlock with your keyring password!")
        keyring::keyring_unlock()
      }
    }
  }

  if (!exists("service")) {
    stop("Please provide a service for which ",
         "to set your API key (e.g. 'ecmwfr')")
  }

  if (!exists("user") | missing(key)) {
    if (!interactive()) {
      stop(
        "wf_set_key needs to be run interactivelly if",
         "`key` is not provided."
        )
    }
    browseURL(wf_key_page(service))
    message("Login or register to get a Personal Access Token")
    key <- getPass::getPass(msg = "Personal Access Token: ")
    if (is.null(key))
      stop("No key supplied.")
  }

  # check login
  # login_ok <- wf_check_login(
  #   user = user,
  #   key = key,
  #   service = service
  # )

  # currently I can't figure out the accounts API endpoint
  # this should/could be used for account validation
  # for now set to OK
  login_ok <- TRUE

  if (!login_ok) {
    stop("Could not validate login information.")
  } else {

    # if ecmwfr keyring is not created do so
    if(keyring::default_backend()$name == "file"){
      if(!("ecmwfr" %in% keyring::keyring_list()$keyring)){
        keyring::keyring_create("ecmwfr")
      }

      # set keyring
      keyring::key_set_with_value(
        service = service,
        username = user,
        password = key,
        keyring = "ecmwfr"
      )

      message("User ", user, " for ", service,
              " service added successfully in keychain file")

    } else {
      keyring::key_set_with_value(
        service = service,
        username = user,
        password = key
      )

      message("User ", user, " for ", service,
              " service added successfully in keychain")
    }

    return(invisible(user))
  }
}
