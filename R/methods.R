# Methods to deal with visualizing / printing
# request info (NEEDS documentation)

as.list.ecmwfr_archetype <- function(x, ...) {
  l <- as.list(body(x))[-1]
}

print.ecmwfr_archetype <- function(x, ...) {
  components <- as.list(x)
  is_dynamic <- lapply(components, class) == "call"
  max_char_name <- max(vapply(names(components), nchar, 1))
  texts <- vapply(components, deparse, "a")
  max_char_text <- max(nchar(texts))

  rpad <- function(text, width) {
    formatC(text, width = -width, flag = " ")
  }

  cat("Request archetype with values: \n")
  for (comps in seq_along(components)) {
    star <- ifelse(is_dynamic[comps], " *", "")
    cat(" ",
        rpad(names(components)[comps], max_char_name),
        "=",
        rpad(texts[comps], max_char_text), star, "\n")
  }
  cat("arguments: ")
  args <- formals(x)
  for (a in seq_along(args)) {
    cat(names(args)[a])
    if (args[[a]] != rlang::expr()) {
      cat(" =", args[[a]])
    }
    if (a != length(args)) cat(", ", sep = "")
  }
}
