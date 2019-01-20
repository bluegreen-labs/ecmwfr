

#' Get secret ECMWF token from file
#'
#' Reading email and secret key from .ecmwfapirc file
#' (located in user home directory).
#'
#' @param verbose boolean, default \code{FALSE}.
#' @return Returns a list with the \code{email} name and \code{key} from
#' the .ecmwfapirc file.
#' @keywords key management
#' @seealso \code{\link[ecmwfr]{wf_set_key}}, \code{\link[ecmwfr]{wf_get_key}}
#' @examples
#' \donttest{
#' ef_key_from_file()
#' }
#'
#' @export
#' @author Reto Stauffer

wf_key_from_file <- function(verbose = FALSE) {
  # Location where the .cdsapirc file is expected
  file = sprintf("%s/%s", path.expand("~"), ".ecmwfapirc")
  if (!file.exists(file)) {
      stop(sprintf("Cannot find file \"%s\".", file))
  }
  # Reading file, extract username and key from "key: <user>:<key>"
  content <- readLines(file)
  if(length(content) == 0)
      stop(sprintf("Problems reading \"%s\", wrong format.", file))
  key   <- content[grep("key.*:.*", content)]
  if(length(key) != 1 ) stop(sprintf("Unexpected content in \"%s\": cannot find key.", file))
  email <- content[grep("email.*:.*", content)]
  if(length(email) != 1 ) stop(sprintf("Unexpected content in \"%s\": cannot find email.", file))

  # Extracting the necessary information
  key <- strsplit(key, ":")[[1L]][2L]
  key <- as.character(parse(text = regmatches(key, regexpr("[^,.]*", key))))
  email <- strsplit(email, ":")[[1L]][2L]
  email <- as.character(parse(text = regmatches(email, regexpr("[^\\S]*", email))))

  if(verbose) {
      cat("CDS login information loaded from .ecmwfapirc\n")
      cat(sprintf("- email:    %s\n", email))
      cat(sprintf("- key:      %s\n", paste(substr(key, 0, 5), "******", sep = "")))
  }

  # Return named list
  return(list(email = email, key = key))
}

# Used to simplify calls within ecmwfr
ecmwf_key_from_file <- wf_key_from_file
