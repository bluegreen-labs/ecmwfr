#' ECMWF services list
#'
#' Returns a list of services
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param simplify simplify the output, logical (default = \code{TRUE})
#' @return returns a nested list or data frame with the ECMWF services
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' # get a list of services
#' wf_services("test@mail.com")
#'
#' # get a list of datasets
#' wf_services("test@mail.com")
#'}

wf_services <- function(
  user,
  simplify = TRUE
){

  # check the login credentials
  if(missing(user)){
    stop("Please provide ECMWF login user / url!")
  }

  # get key from user
  key <- wf_get_key(user = user, service = "webapi")

  # query the status url provided
  response <- httr::GET(
    paste0(wf_server(),"/services"),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = user,
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
    ct <- do.call("rbind", lapply(ct$services, function(x){
      return(data.frame(x['name'], x['href'], stringsAsFactors = FALSE))
    }))
    colnames(ct) <- c("name","url")
  }

  # return content in full
  return(ct)
}
