#' ECMWF dataset list
#'
#' Returns a list of datasets
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param simplify simplify the output, logical (default = \code{TRUE})
#' @param verbose boolean, default \code{FALSE}
#' @return returns a nested list or data frame with the ECMWF datasets
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
#' # get a list of services
#' wf_services("test@mail.com")
#'
#' # get a list of datasets
#' wf_datasets("test@mail.com")
#'}

wf_datasets <- function(email, simplify = TRUE, verbose = FALSE){

  # check the login credentials
  if(missing(email)){
    stop("Please provide ECMWF login email / url!")
  }

  # We need to keep the original email for later!
  # get key from email
  if(is.null(email)) {
    tmp   <- wf_key_from_file(verbose)
    email <- tmp$user; key <- tmp$key; rm(tmp)
  } else {
    key   <- wf_get_key(email)
  }


  # query the status url provided
  response <- httr::GET(
    paste(ecmwf_server(),
          "datasets", sep = "/"),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key),
    encode = "json"
  )

  # trap errors
  if (httr::http_error(response)){
    stop("Your request failed", call. = FALSE)
  }

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  if(simplify){
    # reformat content
    ct <- do.call("rbind", lapply(ct$datasets, function(x){
      return(data.frame(x['name'], x['href'], stringsAsFactors = FALSE))
    }))
    colnames(ct) <- c("name","url")
  }

  # return content
  return(ct)
}
