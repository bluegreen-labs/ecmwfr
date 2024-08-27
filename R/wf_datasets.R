#' List ECMWF Data Store dataset
#'
#' Returns a list of all ECMWF datasets, covering all Data Store services
#' (i.e. CDS, ADS, CEMS). This function is used to validate the datasets
#' queried by \code{\link[ecmwfr]{wf_request}}. For optimization reasons
#' and limit API calls the function is cached and only called once per
#' session (assuming that available products and their information and
#' endpoints aren't updated on a regular sub-daily basis).
#'
#' @param service which service to use, one of \code{webapi}, \code{cds}
#' or \code{ads} (default = webapi)
#' @param simplify simplify the output, logical (default = \code{TRUE}). When
#' not simplified the raw API return is provided as a nested list, for debugging
#' purposes  mostly.
#' @return returns a data frame with the ECMWF Data Store datasets
#' @seealso \code{\link[ecmwfr]{wf_transfer}}
#' \code{\link[ecmwfr]{wf_request}}
#' @export
#' @author Koen Hufkens
#' @importFrom memoise memoise
#' @examples
#'
#' \dontrun{
#' # get a list of ECMWF Data Store datasets
#' wf_datasets()
#'}

wf_datasets <- memoise::memoise(function(
  service = c("cds","ads","cems"),
  simplify = TRUE
  ){

  # for now the API allows listing datasets without
  # authentication (in contrast to the previous API)
  # do they use the API in the backend? - commenting
  # this for now - retaining it should policy change
  # check the login credentials
  #if(missing(user)){
  #  stop("Please provide ECMWF WebAPI or CDS login email or user ID!")
  #}

  # get key
  #key <- wf_get_key(user = user, service = service)

  # Loop over all services and the various data collection names
  # their endpoint urls and the service associated with them
  ct <- lapply(service, function(serv){

    # format the service url
    url <- paste0(wf_server(service = serv),"/catalogue/v1/collections/")

    # query the status url provided
    response <- httr::GET(
      url
    )

    # trap errors
    if (httr::http_error(response)){
      stop("Server not reachable...", call. = FALSE)
    }

    # split out the content of the call
    ct <- httr::content(response)

    # simplify to a data frame with all required parameters
    # a nested list can also be called
    if(simplify){
      collections <- unlist(lapply(ct[["collections"]], "[[", 2))
      ct <- data.frame(
        service = serv,
        name = collections,
        url = paste0(url,collections)
      )
    }

    return(ct)
  })

  # bind everything together if the output
  # should be a dataframe
  if(simplify){
    ct <- do.call("rbind", ct)
  }

  # return content
  return(ct)
})
