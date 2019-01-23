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
ecmwf_server <- function(id) {
    url <- "https://api.ecmwf.int/v1"
    if(missing(id)) return(url)
    return(file.path(url, "services/mars/requests", id))
}

# @rdname ecmwf_server
# @author Reto Stauffer
cds_server   <- function(id) {
    url <- "https://cds.climate.copernicus.eu/api/v2"
    if(missing(id)) return(url)
    return(file.path(url, "tasks", id))
}

# Simple progress spinner
#
# Shows a spinner while waiting for a request to be processed.
#
# @param seconds integer, seconds to sleep
# @param id character missing (default) or a string which will
#    be displayed as 'id'.
# @details Shows a spinner while waiting for a request to be processed.
# If \code{id} (character) is set, the request id will be shown in addition.
#
# @author Koen Kufkens, Reto Stauffer
spinner <- function(seconds, id) {

  # set start time, counter
  start_time <- Sys.time()
  spinner_count <- 1

  # Missing id:
  id <- if (missing(id)) "" else sprintf(" (id: %s)", id)

  if(length(seconds) == 0) seconds <- 1
  while(Sys.time() <= start_time + seconds){

    # slow down while loop
    Sys.sleep(0.2)

    # update spinner message
    message(paste0(c("-","\\","|","/")[spinner_count],
                   " polling server for a data transfer", id, "\r"),
            appendLF = FALSE)

    # update spinner count
    spinner_count <- ifelse(spinner_count < 4, spinner_count + 1, 1)
  }
}
