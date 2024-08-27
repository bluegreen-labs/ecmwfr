#' check ECMWF / CDS data requests
#'
#' Check the validity of a data request by comparing the main dataset
#' to the list provided by \code{\link[ecmwfr]{wf_datasets}}
#'
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF API page
#' @return a data frame with the determined service and url service endpoint
#' @seealso \code{\link[ecmwfr]{wf_set_key}}
#' \code{\link[ecmwfr]{wf_transfer}},\code{\link[ecmwfr]{wf_request}},
#' \code{\link[ecmwfr]{wf_transfer}}
#' @export
#' @author Koen Hufkens
#' @importFrom memoise memoise

wf_check_request <- memoise::memoise(function(
  request
){

  # Stop if not a list
  stopifnot(inherits(request, "list"))

  # check if the dataset name is there
  if(!"dataset_short_name" %in% names(request)){
    stop(
      "Request specification has to contain a \"dataset_short_name\" identifier."
    )
  }

  # query all available dataset in the data stores
  dataset <- try(wf_datasets(), silent = TRUE)

  if(inherits(dataset,"try-error")){
    return(NULL)
  }

  if(request$dataset_short_name %in% dataset$name){

    # split out the service
    service <-dataset$service[which(request$dataset_short_name == dataset$name)]

  } else {
    stop(
      sprintf("Data identifier %s is not found in Data Store datasets.
             Or your login credentials do not match your request.",
              request$dataset), call. = FALSE)
  }

  # select CDS over CEMS when there are multiple choices
  # as data is available on multiple services
  if(length(service)>1){
    service <- service[grep("^cds$", service)]
  }

  # format the service URL
  url <- wf_server(service = service)

  # return service string
  return(data.frame(service, url, stringsAsFactors = FALSE))
})
