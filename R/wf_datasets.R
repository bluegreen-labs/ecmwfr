#' ECMWF dataset list
#'
#' Returns a list of datasets
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param service which service to use, one of \code{webapi}, \code{cds}
#' or \code{ads} (default = webapi)
#' @param simplify simplify the output, logical (default = \code{TRUE})
#' @return returns a nested list or data frame with the ECMWF datasets
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @author Koen Hufkens
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
  simplify = TRUE
  ){

  # check the login credentials
  if(missing(user)){
    stop("Please provide ECMWF WebAPI or CDS login email or user ID!")
  }

  # get key
  key <- wf_get_key(user = user, service = service)

  # query the status url provided
  response <- switch(
    service,
    "cds_beta" = httr::GET(
      "https://cds-beta.climate.copernicus.eu/api/catalogue/v1/collections/"
      ),
    "ads_beta" = httr::GET(
      "https://ads-beta.atmosphere.copernicus.eu/api/catalogue/v1/collections/"
      )
    )

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
    } else if(service == "cds" || service == "ads") {
      # reformat content
      ct <- data.frame(name = unlist(ct),
                       url = sprintf("%s/resources/%s",
                                     wf_server(), unlist(ct)))
    } else {
      collections <- unlist(lapply(ct[["collections"]], "[[", 2))
      urls <- unlist(lapply(ct[["collections"]], "[[", 2))
      ct <- data.frame(
        name = collections,
        url = sprintf(
          "https://cds-beta.climate.copernicus.eu/api/catalogue/v1/collections/%s",
          collections
        )
      )
    }
  }

  # return content
  return(ct)
}
