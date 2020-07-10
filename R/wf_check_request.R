#' check ECMWF / CDS data requests
#'
#' Check the validaty of a data request, and login credentials.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF API page
#' @return a data frame with the determined service and url service endpoint
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}},\code{\link[ecmwfr]{wf_request}}
#' @export
#' @author Koen Hufkens
#' @importFrom memoise memoise

wf_check_request <- memoise::memoise(function(
  user,
  request
){

  # Stop if not a list
  stopifnot(inherits(request, "list"))

  # check MARS requirements
  if(request$dataset == "mars"){
    if(grepl("^netcdf$", tolower(request$format))) {
      if(!"grid" %in% names(request)){
        stop("'mars' requests: 'grid' required if 'format = \"netcdf\"'")
      }
    }
    if(!"target" %in% names(request)){
      stop("'mars' requests: require a 'target' variable in the request.")
    }
  }

  service <- do.call("rbind",
                     lapply(c("webapi","cds","ads"),
                                     function(service){
    dataset <- try(wf_datasets(user, service = service),
                   silent = TRUE)

    if(inherits(dataset,"try-error")){
      return(NULL)
    }

    if (service == "webapi"){
      # sadly had to split this up between services
      # due to changes in dataset naming conventions
      # i.e. no consistent dataset variable can be used
      # see note below

      if(!"dataset" %in% names(request)){
        stop("Request specification has to contain a \"dataset\" identifier.")
      }

      if(request$dataset %in% dataset$name ||
         (request$dataset == "mars" && service == "webapi")){
        return(service)
      }
    } else {

      # on CDS / ADS use the short name variable to avoid conflicts
      # for certain data products (which reuse the dataset parameter)

      if(!"dataset_short_name" %in% names(request)){
        stop("Request specification has to contain a \"dataset_short_name\" identifier.")
      }

      if(request$dataset_short_name %in% dataset$name){
        return(service)
      }
    }
  }))

  if(is.null(service)){
    stop(sprintf("Data identifier %s is not found in Web API or CDS datasets.
                 Or your login credentials do not match your request.",
                 request$dataset), call. = FALSE)
  }

  url <- if(request$dataset == "mars" && service == "webapi") {
    sprintf("%s/services/mars/requests", wf_server(service = service))
  } else if(service == "webapi") {
    sprintf("%s/datasets/%s/requests", wf_server(service = service),
            request$dataset)
  } else {
    wf_server(service = service)
  }

  # return service string
  return(data.frame(service, url, stringsAsFactors = FALSE))
})
