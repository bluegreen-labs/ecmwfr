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
#' @param request a MARS or CDS request as an R list object, with certain
#' parameters modified to take arguments.
#' @param ... list of arguments for which a default value can be set
#' @return a MARS / CDS request
#' @export
#'
#' @examples
#' \dontrun{
#' # format an archetype function
#' ERA_interim <- wf_archetype(
#'  list(class = "ei",
#'     dataset = "interim",
#'     expver = "1",
#'     levtype = "pl",
#'     stream = "moda",
#'     type = "an",
#'     format = "netcdf",
#'     date = date,
#'     grid = paste0(res, "/", res),
#'     levelist = levs,
#'     param = "155.128",
#'     target = "output"),
#' res = 3  # sets default argument
#' )
#'
#' # print output of the function with below parameters
#' str(ERA_interim("20100101", 3, 200))
#'
#' }

wf_archetype <- function(request, ...) {
  query_exp <- rlang::enexpr(request)
  extra_args <- match.call(expand.dots = FALSE)$`...`
  has_default <- names(extra_args) != ""

  vars <- unique(c(all.vars(query_exp),
                   names(extra_args[has_default]),
                   as.character(extra_args[!has_default])
  ))

  args <- setNames(rep(list(rlang::expr()),
                       length(vars)),
                   vars)
  args[vars %in% c(names(extra_args))] <- extra_args[has_default]

  f <- rlang::new_function(args, query_exp)
  class(f) <- c("ecmwfr_archetype", class(f))
  f
}
