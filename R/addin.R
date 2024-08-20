# addin behaviour specifics
pythonbeta2list_Addin <- function() {
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

  if(missing(python_text)){
    stop("No input text provided")
  }

  # substitute inconsistent quotes, sorting the f-ing API mess
  # for consistency
  python_text <- gsub("\\\"","\'", python_text)

  # split string on line breaks
  line_breaks <- strsplit(python_text, "\\n")[[1]]

  leading <- line_breaks[grep("dataset", line_breaks)]
  trailing <- line_breaks[grep("target", line_breaks)]

  # clean up leading and trailing ends if any
  if (nchar(leading) == 0 || length(leading) == 0){
    stop("Incomplete query selection: dataset is missing")
  }

  # dropping field name and removing quotes
  leading <- gsub("dataset = ","", leading)
  leading <- gsub("\'","", leading)

  # clean up leading and trailing ends if any
  if (nchar(trailing) == 0 || length(trailing) == 0){
    trailing <- "TMPFILE"
  } else {
    # dropping field name and removing quotes
    trailing <- gsub("target = ","", trailing)
    trailing <- gsub("\'","", trailing)
  }

  # grab anything between {} within ()
  c_brackets <- try(gsub("[\\{\\}]", "",
                         regmatches(python_text,
                                    gregexpr("\\{.*?\\}", python_text))[[1]]))

  # check if strings have content
  if(length(c_brackets) == 0){
    stop("Incomplete query selection")
  }

  # trap the goddamn inconsistent MARS json formatting issue
  c_brackets <- gsub("\n| ","", c_brackets)
  if(substr(c_brackets, nchar(c_brackets),nchar(c_brackets)) == ","){
    c_brackets <- substr(c_brackets, 1, nchar(c_brackets)-1)
  }

  # Remove trailing commas (",]")
  c_brackets <- gsub(",]", "]", c_brackets)
  c_brackets <- paste0("{",c_brackets,"}")
  c_brackets <- gsub("\'", "\"", c_brackets)

  # read in data as list
  c_list <- jsonlite::fromJSON(c_brackets)

  # add leading and trailing bits
  # to request list
  c_list <- c(dataset_short_name = leading, c_list, target = trailing)

  # clean up leading and trailing ends if any
  if (nchar(leading) == 0 || length(leading) == 0){
    c_list$dataset_short_name <- gsub('\\n|,\\n| |"','', leading)
  }

  if (nchar(trailing) == 0 || length(trailing) == 0){
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

