#' Dynamically modify MARS / CDS request parameters
#'
#' Provides a way to quickly modify MARS / CDS request parameters. The function
#' will only replace existing parameters, all other parameters specified will
#' be ignored.
#'
#' @param request a MARS or CDS request formatted as an R list()
#' @param ... variables to replace in the provided rqquest
#' @return a MARS / CDS request
#' @export
#'
#' @examples
#' \dontrun{
#' # a MARS request for webapi ECMWF data
#' base_request <- list(stream = "oper",
#' levtype = "sfc",
#' param = "165.128/166.128/167.128",
#' dataset = "interim",
#' step = "0",
#' grid = "0.75/0.75",
#' time = "00/06/12/18",
#' date = "2014-07-01/to/2014-07-31",
#' type = "an",
#' class = "ei",
#' area = "73.5/-27/33/45",
#' format = "netcdf",
#' target = "tmp.nc")
#'
#'
#' # add an additional month of data and grow the extent by a degree
#' # from 45 to 46 degrees North
#' new_request <- wf_modify_request(request = base_request,
#'                                 date = "2014-07-01/to/2014-08-31",
#'                                 area = "73.5/-27/33/46")
#' print(str(new_request))
#'}

wf_modify_request <- function(request, ...){

  # check the request statement
  if(missing(request) || !is.list(request)){
    stop("not a request")
  }

  # load dot arguments
  dot_args <- list(...)

  # loop over everything
  do.call("c",lapply(names(request), function(request_name){

    # get a replacement value if matching
    # a name in the original request
    replacement <- dot_args[request_name]

    # no clue why is.null doesn't work in this case
    # print might just fill this with NULL
    if(is.na(names(replacement))) {
      return(request[request_name])
    } else {
      return(replacement)
    }
  }))
}
