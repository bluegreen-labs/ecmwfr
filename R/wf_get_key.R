#' Get secret ECMWF / CDS token
#'
#' Returns you token set by \code{\link[ecmwfr]{wf_set_key}}
#'
#' @param user user (email address) used to sign up for the ECMWF data service
#' @param service service associated with credentials ("webapi" or "cds")
#' @return the key set using \code{\link[ecmwfr]{wf_set_key}} saved
#' in the keychain
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
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

wf_get_key <- function(user, service = "webapi") {

  # unlock the keyring when required, mostly so
  # only the "env" option does not require this
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

  # grab keyring
  keyring::key_get(
    service = make_key_service(service),
    username = user,
    keyring = ifelse(keyring::default_backend()$name == "file",
                     "ecmwfr",
                     NULL))
}
