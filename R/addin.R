
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
  MARS_text <- MARS_text[lengths(MARS_text) == 2]

  max_chars <- max(vapply(MARS_text, function(t) nchar(t[1]), 1))

  MARS_text  <- lapply(seq_along(MARS_text), function(t) {
    text <- MARS_text[[t]]
    if (length(text) != 2) {
      return("")
    }
    last_char <- substr(text[2], nchar(text[2]), nchar(text[2]))
    if (last_char == ",") {
      text[2] <- strtrim(text[2], nchar(text[2]) - 1)
    }

    text[2] <- gsub('"', "", text[2])

    text[1] <- formatC(text[1], width = -max_chars, flag = " ")
    paste0("  ", text[1], ' = "', text[2], '"', sep = "")
  })

  return(paste0("list(\n",
                paste0(unlist(MARS_text), collapse = ",\n"),
                "\n)"))
}
