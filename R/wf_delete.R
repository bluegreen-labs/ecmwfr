#' ECMWF delete request
#'
#' Deletes a staged download from the queue
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param url url to query
#' @param verbose show feedback on processing
#' @param type character, one of \code{ecmwf} or \code{cds} depending
#' on the data set to be deleted.
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
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
# TODO: example might need an update (if even required).

wf_delete <- function(
  email,
  url,
  type = "ecmwf",
  verbose = TRUE
){

  # check the login credentials
  if(missing(email) | missing(url)){
    stop("Please provide ECMWF login email / url!")
  }

  # Checking input argument 'type'
  type <- match.arg(type, c("ecmwf", "cds"))

  # get key
  if(is.null(email)) {
    tmp   <- get(sprintf("%s_key_from_file", type))(verbose)
    email <- tmp$email; key <- tmp$key; rm(tmp)
  } else {
    key <- get(sprintf("%s_get_key", type))(email)
  }

  # remove a queued download
  # Differs for ecmwf and cds requests.
  # For CDS: note that 'email' is simply a copy of 'user'
  if(type == "cds") {
    response <- httr::DELETE(
      url,
      httr::authenticate(email, key),
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json")
    )
  } else {
    response <- httr::DELETE(
      url,
      httr::add_headers(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
        "From" = email,
        "X-ECMWF-KEY" = key)
    )
  }

  # check purging of request
  if(response$status == 204){
    if (verbose){
      message("- request purged from queue!")
    } else {
      invisible()
    }
  } else {
    warning("Request not purged from queue, check download!")
  }
}
