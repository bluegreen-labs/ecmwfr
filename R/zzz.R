#' load default server names
#'
#' @author Koen Kufkens
ecmwf_server <- function(id) "https://api.ecmwf.int/v1/"

#' @rdname ecmwf_server
#' @author Reto Stauffer
cds_server   <- function(id) {
    url <- "https://cds.climate.copernicus.eu/api/v2"
    if(missing(id)) return(url)
    return(file.path(url, "tasks", id))
}

#' Simple progress spinner
#'
#' Shows a spinner while waiting for a request to be processed.
#'
#' @param seconds integer, seconds to sleep
#' @param id character missing (default) or a string which will
#'    be displayed as 'id'.
#' @author Koen Kufkens, Reto Stauffer
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
