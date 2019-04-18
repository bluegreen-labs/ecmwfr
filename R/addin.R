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

  return(paste0("request <- list(\n",
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

  python_text <- gsub('\'','"',python_text)

  # grab anything between ()
  brackets <- try(gsub("[\\(\\)]", "",
                   regmatches(python_text,
                              gregexpr("\\(.*?\\)", python_text))[[1]]))

  # grab anything between {} within ()
  c_brackets <- try(gsub("[\\{\\}]", "",
                         regmatches(python_text,
                                    gregexpr("\\{.*?\\}", python_text))[[1]]))

  # check if strings have content
  if(length(brackets) == 0 || length(c_brackets) == 0){
    stop("Incomplete query selection")
  }

  # trap the goddamn inconsistent MARS json formatting issue
  c_brackets <- gsub("\n| ","", c_brackets)
  if(substr(c_brackets, nchar(c_brackets),nchar(c_brackets)) == ","){
    c_brackets <- substr(c_brackets, 1, nchar(c_brackets)-1)
  }

  # read in data as list
  c_list <- jsonlite::fromJSON(paste0("{",c_brackets,"}"))

  # grab the trailing bit between } and ) i.e. the dataste name
  leading <- try(gsub("[\\(\\{]", "",
                       regmatches(python_text,
                                  gregexpr("\\(.*?\\{", python_text))[[1]]))

  # grab the leading bit between ( and } i.e. the target
  trailing <- try(gsub("[\\}\\)]", "",
                       regmatches(python_text,
                                  gregexpr("\\}.*?\\)", python_text))[[1]]))

  # clean up leading and trailing ends if any
  if (nchar(leading) != 0){
    c_list$dataset <- gsub('\\n|,\\n| |"','', leading)
  }

  if (nchar(trailing) != 0){
    c_list$target <- gsub('\\n|,\\n| |"','', trailing)
  }

  # clean up list values
  list_values <- lapply(c_list, function(l){
    if(length(l) == 1){
      paste0('"',l,'"')
    } else {
      l
    }
  })

  # returned cleaned up list
  return(
    paste0("request <- list(\n",
           paste0(
             paste0("  ", names(c_list), ' = ', list_values),
             collapse = ",\n"),
           "\n)"))
}
