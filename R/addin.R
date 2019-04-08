# addin behaviour specifics
MARS2list_Addin <- function() {
  context   <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$text
  request  <- MARS_to_list(selection)
  location <- context$selection[[1]]$range
  rstudioapi::modifyRange(location = location,
                          text = request,
                          id = context$id)
}

# conversion function to translate a MARS query into
# a ecmwfr list statement
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

# addin behaviour specifics
python2list_Addin <- function() {
  context   <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$text
  request  <- python_to_list(selection)
  location <- context$selection[[1]]$range
  rstudioapi::modifyRange(location = location,
                          text = request,
                          id = context$id)
}

# conversion function to translate a python python query into
# a ecmwfr list statement
python_to_list <- function(python_text) {

  # remove annoying characters
  python_text  <- gsub(" |\\'|\\\"|\\,|\\(|\\)|\\}|\\{", "", python_text)

  # split on new line
  python_text <- strsplit(python_text,"\n")[[1]]

  # remove the retrieve statement of the
  # python function
  python_text <- python_text[grep("retrieve", python_text, invert = TRUE)]

  # remove fields with no characters
  python_text <- python_text[lapply(python_text,nchar)>0]

  # convert first occurence : into =
  python_text <- unlist(lapply(python_text, function(s){
    sub(":","=",s)
  }))

  # loop over all elements, compose nicely and
  # trap those with one element (either the dataset or the target file)
  python_text <- lapply(python_text, function(s){
    parts <- strsplit(s, "=")[[1]]
    if (length(parts) == 1){
      if(grepl("download",parts[1])){
        paste0("  ", "target", ' = "', parts[1], '"', sep = "")
      } else {
        paste0("  ", "dataset", ' = "', parts[1], '"', sep = "")
      }
    } else {
      paste0("  ", parts[1], ' = "', parts[2], '"', sep = "")
    }
  })

  return(paste0("list(\n",
               paste0(unlist(python_text), collapse = ",\n"),
               "\n)"))
}
