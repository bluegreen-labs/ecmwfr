#' Set secret CDS token
#'
#' Saves the token to your local keychain under
#' a service called "ecmwfr".
#'
#' @param user chracter, user id used to sign up for the CDS data server
#' @param key token provided by CDS
#' @details Wrapper function for \code{\link[ecmwfr]{wf_set_key}}.
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{cds_get_key}}, \code{\link[ecmwfr]{cds_key_from_file}}
#' @export
#' @author Koen Kufkens, Reto Stauffer
#' @examples
#'
#' \donttest{
#' # set key
#' cds_set_key(user = "1234", key = "abc123foo")
#'
#' # get key
#' cds_get_key(user = "1234")
#'}

cds_set_key <- function(user, key) wf_set_key(user, key)

#' Get secret CDS token
#'
#' Returns you token set by \code{\link[ecmwfr]{cds_set_key}}.
#'
#' @param user chracter, user id used to sign up for the CDS data server
#' @return the key set using \code{\link[ecmwfr]{cds_set_key}} saved
#' in the keychain
#' @details Wrapper function for \code{\link[ecmwfr]{wf_set_key}}.
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{cds_set_key}}, \code{\link[ecmwfr]{cds_key_from_file}}
#' @examples
#'
#' \donttest{
#' # set key
#' cds_set_key(user = "1234", key = "abc123foo")
#'
#' # get key
#' cds_get_key(user = "1234")
#'}
#'
#' @export
#' @author Koen Kufkens, Reto Stauffer

cds_get_key <- function(user) wf_get_key(user)


#' Get secret CDS token from file
#'
#' Reading username and secret key from .cdsapirc file
#' (located in user home directory).
#'
#' @param verbose boolean, default is \code{FALSE}.
#' @return Returns a list with the \code{user}, \code{email}, and \code{key}.
#'  \code{email == user}, used to simplify the calls.
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{cds_set_key}}, \code{\link[ecmwfr]{cds_get_key}}
#' @examples
#' \donttest{
#' cds_key_from_file()
#' }
#'
#' @export
#' @author Reto Stauffer

cds_key_from_file <- function(verbose = FALSE) {
  # Location where the .cdsapirc file is expected
  file = sprintf("%s/%s", path.expand("~"), ".cdsapirc")
  if (!file.exists(file)) {
      stop(sprintf("Cannot find file \"%s\".", file))
  }
  # Reading file, extract username and key from "key: <user>:<key>"
  content <- readLines(file)
  content <- gsub("key:\\s+", "", content[grep("^key:.*$", content)])
  if(length(content) == 0)
      stop(sprintf("Problems reading \"%s\", wrong format.", file))
  res <- stats::setNames(do.call(list, as.list(strsplit(content, ":")[[1]])), c("user", "key"))

  if(verbose) {
      message(sprintf("- CDS login (from .cdsapirc): user ID: %s, key = %s",
          res$user, paste(substr(res$key, 0, 5), "******", sep = "")))
  }
  # Append "user = email": for cds the 'user' is used, however
  # to be able to simplify the calls returning both, user and email!
  res$email <- res$user
  return(res)
}


