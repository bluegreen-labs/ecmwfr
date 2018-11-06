#' ECMWF services list
#'
#' Returns a list of services
#'
#' @param email email address used to sign up for the ECMWF data service and
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param simplify simplify the output, logical (default = TRUE)
#' @return returns a nested list or data frame with the ECMWF services
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @examples
#'
#' \donttest{
#' # set key
#' wf_set_key(email = "test@mail.com", key = "123")
#'
#' # get key
#' wf_get_key(email = "test@mail.com")
#'}

wf_services <- function(
  email
){

  # check the login credentials
  if(missing(email)){
    stop("Please provide ECMWF login email / url!")
  }

  # get key from email
  key <- wf_get_key(email)

  # query the status url provided
  response <- httr::GET(
    paste(ecmwf_server(),
          "services", sep = "/"),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = email,
      "X-ECMWF-KEY" = key),
    encode = "json"
  )

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  if(simplify){
    # reformat content
    ct <- do.call("rbind", lapply(ct$services, function(x){
      return(data.frame(x['name'], x['href'], stringsAsFactors = FALSE))
    }))
    colnames(ct) <- c("name","url")
  }

  # return content in full
  return(ct)
}
