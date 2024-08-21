#' Delete ECMWF Data Store request
#'
#' Deletes a staged download from the queue when not using R6 methods.
#'
#' @param url url to query
#' @param user user, generally not set (default = "ecmwfr"), used by \code{\link[ecmwfr]{wf_set_key}}
#' @param verbose show feedback on processing
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # delete request
#' job_url <- file$get_url()
#' wf_delete(url = job_url)
#'}

wf_delete <- function(
  url,
  user = "ecmwfr",
  verbose = TRUE
){

  # check the login credentials
  if(missing(url)){
    stop("Please provide ECMWF login user / url!")
  }

  # get key
  key <- wf_get_key(user = user)

  #  get the response for the query provided
  response <- try(httr::DELETE(
    url,
    httr::add_headers(
      "PRIVATE-TOKEN" = key
      )
    ), silent = TRUE
  )

  # trap bad urls
  if(inherits(response, "try-error")){
    stop("Request not purged from queue, check download!")
  } else {

    # trap general http error
    if (httr::http_error(response)) {
      stop("Request not purged from queue, check download!")
    }

    # otherwise report success
    if (verbose){
      message("- request purged from queue!")
    }

    # return content of call
    ct <- httr::content(response)
    invisible(ct)
  }
}
