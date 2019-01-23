#' ECMWF WebAPI user info query
#'
#' Returns user info for the ECMWF WebAPI
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @return returns a data frame with user info
#' @keywords data download, climate, re-analysis
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_services}}
#' \code{\link[ecmwfr]{wf_datasets}}
#' @export
#' @examples
#'
#' \dontrun{
#' # set key
#' wf_set_key(user = "test@mail.com", key = "123")
#'
#' # get user info
#' wf_user_info("test@mail.com")
#'}

wf_user_info <- function(
  user
){

  # check the login credentials
  if(missing(user)){
    stop("Please provide ECMWF login user / url!")
  }

  # get key from user
  key <- wf_get_key(user)

  # query the status url provided
  response <- httr::GET(
    paste(wf_server(),
          "/who-am-i", sep = "/"),
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

  # return content
  return(data.frame(ct))
}
