# load default server names
#
# Returns the url of the data servers for downloading
# public ECMWF data sets or data sets for the Copernicus CDS.
#
# @param id string, id of the request.
# @details The handling of CDS requests is slightly different from
# the one of ECMWF public data sets. To be able to get the status
# of a request for CDS data sets we do have to check the status
# by calling the 'task' urls. If an \code{id} is given the
# corresponding 'task' url will be returned. Used in
# \code{\link[ecmwfr]{cds_request} and \code{\link[ecmwfr]{cds_transfer}}
# (to be more explicit: in \code{\link[ecmwfr]{wf_transfer} if
# \code{type == "cds"}).
#
# @author Koen Kufkens
wf_server <- function(id, service = "webapi") {

  # match arguments, if not stop
  service <- match.arg(service, c("webapi", "cds"))

  # set base urls
  webapi_url <- "https://api.ecmwf.int/v1"
  cds_url <- "https://cds.climate.copernicus.eu/api/v2"

  if (service == "webapi"){
      if(missing(id)){ return(webapi_url)
    } else {
      return(file.path(webapi_url, "services/mars/requests", id))
    }
  } else {
    if(missing(id)){
      return(cds_url)
    } else {
      return(file.path(cds_url, "tasks", id))
    }
  }
}

# Simple progress spinner
#
# Shows a spinner while waiting for a request to be processed.
#
# @param seconds integer, seconds to sleep
#
# @details Shows a spinner while waiting for a request to be processed.
# If \code{id} (character) is set, the request id will be shown in addition.
#
# @author Koen Kufkens, Reto Stauffer
spinner <- function(seconds){

  # set start time, counter
  start_time <- Sys.time()
  spinner_count <- 1

  while(Sys.time() <= start_time + seconds){

    # slow down while loop
    Sys.sleep(0.2)

    # update spinner message
    message(paste0(c("-","\\","|","/")[spinner_count],
                   " polling server for a data transfer\r"),
            appendLF = FALSE)

    # update spinner count
    spinner_count <- ifelse(spinner_count < 4, spinner_count + 1, 1)
  }
}

# Show message if user exits the function (interrupts execution)
# or as soon as an error will be thrown.
exit_message <- function(id, path, target){
  exit_msg <-  paste(
    "Even after exiting your request is still beeing processed!",
    "Visit https://cds.climate.copernicus.eu/cdsapp#!/yourrequests",
    "to manage (download, retry, delete) your requests",
    "or to get ID's from previous requests.",
    "Retry downloading as soon as as completed:",
    sprintf("  - wf_transfer(<user>, \"%s\", \"cds\", \"%s\", \"%s\")",
            id, path, file),
    "Delete the job upon completion using:",
    sprintf("  - wf_delete(<user>, \"%s\", \"cds\")", id),
    sep = "\n  ")
  message(sprintf("- Your request has been submitted to CDS.\n  %s", exit_msg))
}


# Startup message when attaching the package.
.onAttach <- function(libname = find.package("ecmwfr"), pkgname = "ecmwfr") {
  vers <- as.character(utils::packageVersion("ecmwfr"))
  txt <- paste("\n     This is 'ecmwfr' version ", vers,". Please respect the terms of use:\n",
               "     - https://cds.climate.copernicus.eu/disclaimer-privacy\n",
               "     - https://www.ecmwf.int/en/terms-use\n")
  if(interactive()) packageStartupMessage(txt)
}
