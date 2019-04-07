
MARS2list_Addin <- function() {
  context   <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$text

  request  <- MARS_to_list(selection)
  location <- context$selection[[1]]$range

  rstudioapi::modifyRange(location = location,
                          text = request,
                          id = context$id)
}


MARS_to_list <- function(MARS_text) {
  MARS_text <- strsplit(MARS_text, "\n")[[1]]
  MARS_text <- strsplit(MARS_text, "=")

  MARS_text  <- lapply(MARS_text[lengths(MARS_text) == 2], function(t) {
    if (length(t) != 2) {
      return("")
    }
    last_char <- substr(t[2], nchar(t[2]), nchar(t[2]))
    if (last_char == ",") {
      t[2] <- strtrim(t[2], nchar(t[2]) - 1)
    }

    t[2] <- gsub('"', "", t[2])

    paste0(t[1], ' = "', t[2], '"', sep = "")
  })

  return(paste0("list(",
                paste0(unlist(MARS_text), collapse = ",\n"),
                ")"))
}
