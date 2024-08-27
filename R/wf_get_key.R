#' Get secret ECMWF / CDS token
#'
#' Returns you token set by \code{\link[ecmwfr]{wf_set_key}}
#'
#' @param user user (email address) used to sign up for the ECMWF data service
#' @return the key set using \code{\link[ecmwfr]{wf_set_key}} saved
#' in the keychain
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
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
#'}

wf_get_key <- function(user = "ecmwfr") {

  # service is hard coded, but kept here should policy change
  service = "ecmwfr"

  # system environments variables override the keyring
  # by default
  key <- Sys.getenv("ecmwfr_PAT")
  if(nchar(key)>0){
    return(key)
  }

  # unlock the keyring when required, mostly so
  # only the "env" option does not require this
  if (keyring::default_backend()$name != "env") {
    if (keyring::default_backend()$name == "file") {
      if ("ecmwfr" %in% keyring::keyring_list()$keyring) {
        if(keyring::keyring_is_locked(keyring = "ecmwfr")){
          message("Your keyring is locked \n",
                  "please unlock with your keyring password!")
          keyring::keyring_unlock(keyring = "ecmwfr")
        }
      } else {
        stop("Can't find your credentials in the ecmwfr keyring file")
      }
    } else {
      if (keyring::keyring_is_locked()) {
        message("Your keyring is locked \n",
                "please unlock with your keyring password!")
       keyring::keyring_unlock()
      }
    }
  }

  # can't use ifelse as the keyring argument will
  # throw warnings which gives issues for unit tests
  if(keyring::default_backend()$name == "file"){
    keyring::key_get(
      service = service,
      username = user,
      keyring = "ecmwfr")
  } else {
    keyring::key_get(
      service = service,
      username = user)
  }
}
