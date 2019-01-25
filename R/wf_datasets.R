#' ECMWF dataset list
#'
#' Returns a list of datasets
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param service service to use ecmwf webapi or cds (default = "webapi")
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

wf_datasets <- function(
  user,
  service = "webapi",
  simplify = TRUE,
  verbose = FALSE
  ){

  # check the login credentials
  if(missing(user)){
    stop("Please provide ECMWF WebAPI or CDS login email / url!")
  }

  # get key
  key <- wf_get_key(user)

  # query the status url provided
  if (service == "webapi"){
  response <- httr::GET(
    paste0(wf_server(),"/datasets"),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/json",
      "From" = user,
      "X-ECMWF-KEY" = key),
    encode = "json")
  } else {
    response <- httr::GET(sprintf("%s/resources/",
                                  wf_server(service = "cds")))
  }

  # trap errors
  if (httr::http_error(response)){
    stop("Your request failed - check credentials", call. = FALSE)
  }

  # check the content, and status of the
  # download
  ct <- httr::content(response)

  if(simplify){
    if(service == "webapi"){
      # reformat content
      ct <- do.call("rbind", lapply(ct$datasets, function(x){
        return(data.frame(x['name'], x['href'], stringsAsFactors = FALSE))
      }))
      colnames(ct) <- c("name","url")
    } else {
      # reformat content
      ct <- data.frame(name = unlist(ct),
                       url = sprintf("%s/resources/%s",
                                     wf_server(), unlist(ct)))
    }
  }

  # return content
  return(ct)
}
