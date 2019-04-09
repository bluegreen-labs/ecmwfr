#' Get secret ECMWF / CDS token
#'
#' Returns you token set by \code{\link[ecmwfr]{wf_set_key}}
#'
#' @param user user (email address) used to sign up for the ECMWF data service
#' @param service service associated with credentials ("webapi" or "cds")
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
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(user = "test@mail.com")
#'}

wf_get_key <- function(user, service = "webapi"){

  if(keyring::default_backend()$name != "env"){
   if(keyring::keyring_is_locked()){
      message("Your keyring is locked please unlock with your keyring password!")
      keyring::keyring_unlock()
    }
  }

  keyring::key_get(service = make_key_service(service), username = user)
}
