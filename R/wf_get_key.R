#' Get secret ECMWF token
#'
#' Returns you token set by \code{\link[ecmwfr]{wf_set_key}}
#'
#' @param email email address used to sign up for the ECMWF data service
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
#' wf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(email = "test@mail.com")
#'}

wf_get_key <- function(email){
  keyring::key_get(service = "ecmwfr",
                   username = email)
}

# Used to simplify the calls
ecmwf_get_key <- wf_get_key
