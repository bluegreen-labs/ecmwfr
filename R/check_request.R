#' Check requests
#'
#' There are some parameter combinations which are not allowed
#' and will result in an error when sending the requests to
#' via API. the \code{\link[ecmwfr]{check_request}} function tries
#' to avoid these problems before sending a request. See 'Details'.
#'
#' @param x list of parameters (as for \code{\link[emcwfr]{wf_request}},
#' \code{\link[ecmwfr]{cds_request}}).
#' @return Returns the request (might, to avoid problems, modify the
#' user request.
#'
#' @details
#' Some of the checks:
#' \itemize{
#'    \item will raise an error if the \code{dataset} identifier is missing.
#'    \item if \code{dataset = "mars"} and \code{format = "netcdf"}: if no
#'       \code{grid} specification is given: stop. Reason: grib to netcdf
#'       conversion will only work on a regular_ll grid.
#' }
#'
#' @export
#' @author Reto Stauffer
check_request <- function(x) {

    # If no 'dataset' is set: stop
    stopifnot(inherits(x, "list"))
    if(!"dataset" %in% names(x)){
        stop("Request specification has to contain a \"dataset\" identifier.")
    }

    # Check if function exists. If not, return
    cmd <- sprintf("check_request_%s", x$dataset)
    check_user_request <- tryCatch(eval(parse(text = cmd)),
                                   error = function(e) e)

    # Function not found: return original list
    if(inherits(check_user_request, "error")) return(x)

    # If the evaluated cmd is not a function: return originl list
    if(!is.function(check_user_request)) return(x)

    # Else forward 'request' to function 'checkfun' and return the
    # result of the 'check_request_<dataset>' method.
    return(check_user_request(x))
}

check_request_mars <- function(x) {
    if(grepl("^netcdf$", tolower(x$format))) {
        if(!"grid" %in% names(x))
            stop(paste("'mars' requests: 'grid' definition required if 'format = \"netcdf\"'",
                       "as grib to netcdf conversion is only possible for regular ll grids.!"))
    }
    # Requires a target file name, the name
    # where the file will be stored on the ECMWF side.
    #TODO: if missing: use temporary file name? Would avoid
    # a user to submit different requests with the very same name
    # which would overwrite the previous one.
    if(!"target" %in% names(x))
        stop(paste("'mars' requests: require a 'target' variable in the request. Name",
                   " of the file where the temporary file will be stored on the ECMWF server."))
    return(x)
}


