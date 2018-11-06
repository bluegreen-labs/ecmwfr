# load default server names
ecmwf_server <- function(){'https://api.ecmwf.int/v1/'}

# simple spinner
spinner <- function(seconds){

  # set start time, counter
  start_time <- Sys.time()
  spinner_count <- 1

  while(Sys.time() <= start_time + seconds){

    # slow down while loop
    Sys.sleep(0.2)

    # update spinner message
    message(paste0(c("-","\\","|","/")[spinner_count],
                   " Continuously polling server for a data transfer. \r"),
            appendLF = FALSE)

    # update spinner count
    spinner_count <- ifelse(spinner_count < 4, spinner_count + 1, 1)
  }
}
