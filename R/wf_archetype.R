#' Creates an archetype function
#'
#' Creates a universal MARS / CDS formatting function, in ways
#' similar to \code{wf_modify_request()} but the added advantage
#' that you could code for the use of dynamic changes in the
#' parameters provided to the resulting custom function.
#'
#' Contrary to a simple replacement as in \code{wf_modify_request()} the
#' generated functions are considered custom user written. Given the potential
#' for complex formulations and formatting commands NO SUPPORT for the
#' resulting functions can be provided. Only the generation of a valid function
#' will be guaranteed and tested for.
#'
#' @param request a MARS or CDS request as an R list object.
#' @param dynamic_fields character vector of fields that could be changed.
#'
#' @return a function that takes `dynamic_fields` as arguments and returns a
#' request as an R list object.
#' @export
#'
#' @examples
#' \dontrun{
#' # format an archetype function
#' ERAI <- wf_archetype(
#'   request = list(stream = "oper",
#'                  levtype = "sfc",
#'                  param = "165.128/166.128/167.128",
#'                  dataset = "interim",
#'                  step = "0",
#'                  grid = "0.75/0.75",
#'                  time = "00/06/12/18",
#'                  date = "2014-07-01/to/2014-07-31",
#'                  type = "an",
#'                  class = "ei",
#'                  area = "73.5/-27/33/45",
#'                  format = "netcdf",
#'                  target = "tmp.nc"),
#'   dynamic_fields = c("date", "time")
#' )
#'
#' # print output of the function with below parameters
#' str(ERA_interim("20100101", 3, 200))
#'
#' }
wf_archetype <- function(request, dynamic_fields) {
  if (!requireNamespace("rlang", quietly = TRUE)) {
    stop(
      "wf_archetype needs the rlang package.
      Install it with install.packages(\"rlang\")"
    )
  }

  # check the request statement
  if (missing(request)) {
    stop("not a request")
  }

  if (missing(dynamic_fields)) {
    stop("missing dynamic_fields")
  }

  in_request <- dynamic_fields %in% names(request)
  if (sum(!in_request) != 0) {
    stop(
      "dynamic field(s) not in original request: ",
      paste0(dynamic_fields[!in_request], collapse = ", ")
    )
  }

  args <- request[dynamic_fields]
  request[dynamic_fields] <- lapply(dynamic_fields, as.symbol)

  new_archetype(args, request)
}
