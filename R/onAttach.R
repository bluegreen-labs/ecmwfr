

# Startup message when attaching the package.
.onAttach <- function(libname = find.package("ecmwfr"), pkgname = "ecmwfr") {
    vers <- as.character(utils::packageVersion("ecmwfr"))
    txt <- paste("\n     This is 'ecmwfr' version ", vers,". Please respect the terms of use:\n",
                 "     - https://cds.climate.copernicus.eu/disclaimer-privacy\n",
                 "     - https://www.ecmwf.int/en/terms-use\n")
    if(interactive()) packageStartupMessage(txt)
}
