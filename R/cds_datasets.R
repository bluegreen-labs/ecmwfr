#' CDS dataset list
#'
#' Returns a list of datasets available on the climate data store servers.
#'
#' @param user string, user ID used to sign up for the CDS data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{cds_set_key}}.
#' Note: can also be set to \code{NULL}, in this case user and key will
#' be read from the \code{.cdsapirc} file (located in your home folder).
#' @param simplify simplify the output, logical (default = \code{TRUE})
#' @param verbose boolean, default \code{FALSE}.
#' @return returns a nested list or data frame with the ECMWF datasets
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{cds_set_key}}
#' \code{\link[ecmwfr]{cds_transfer}}
#' \code{\link[ecmwfr]{cds_request}}
#' @export
#' @author Reto Stauffer
#' @examples
#'
#' \donttest{
#' # get a list of services
#' cds_services(user = NULL)
#'}

cds_datasets <- function(user, simplify = TRUE, verbose = FALSE) {

  # No user, no fun!
  if(missing(user))
    stop("Please provide CDS user ID (or set user = NULL, see manual)")

  # check the login credentials
  # If 'user == NULL' load user login information from
  # '~/.cdsapirc' file. Else load key via local keyring.
  if(is.null(user)) {
    tmp  <- cds_key_from_file(verbose = verbose)
    user <- tmp$user; key <- tmp$key; rm(tmp)
  } else {
    # get key from uername
    key <- cds_get_key(user)
  }

  # query the status url provided
  response <- httr::GET(sprintf("%s/resources/", cds_server()))

  # trap errors
  if (httr::http_error(response)){
    stop("Your request failed", call. = FALSE)
  }

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  if(simplify){
    # reformat content
    ct <- data.frame(name = unlist(ct),
                     url = sprintf("%s/resources/%s", cds_server(), unlist(ct)))
  }

  # return content
  return(ct)
}




