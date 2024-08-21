#' Methods to deal with visualizing / printing
#' requesting info from the archetype constructor
#'
#' @param x archetype object
#' @export

print.ecmwfr_archetype <- function(x, ...) {
  components <- x()
  is_dynamic <- names(components) %in% names(formals(x))
  max_char_name <- max(vapply(names(components), nchar, 1))
  texts <- vapply(components, deparse, "a")
  max_char_text <- max(nchar(texts))

  rpad <- function(text, width) {
    formatC(text, width = -width, flag = " ")
  }

  message("Request archetype with values:")
  for (comps in seq_along(components)) {
    star <- ifelse(is_dynamic[comps], " *", "")
    message(" ",
        rpad(names(components)[comps], max_char_name),
        "=",
        rpad(texts[comps], max_char_text), star)
  }
  message(" * : dynamic fields")
}
