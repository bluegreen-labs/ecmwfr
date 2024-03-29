% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wf_product_info.R
\name{wf_product_info}
\alias{wf_product_info}
\title{Renders product lists for a given dataset and data service}
\usage{
wf_product_info(dataset, user, service = "webapi", simplify = TRUE)
}
\arguments{
\item{dataset}{character, name of the data set for which the product
information should be loaded.}

\item{user}{string, user ID used to sign up for the CDS / ADS data service,
used to retrieve the token set by \code{\link[ecmwfr]{wf_set_key}}.}

\item{service}{which service to use, one of \code{webapi}, \code{cds}
or \code{ads} (default = webapi)}

\item{simplify}{boolean, default \code{TRUE}. If \code{TRUE} the description
will be returned as tidy data instead of a nested list.}
}
\value{
Downloads a tidy data frame with product descriptions from CDS. If
\code{simplify = FALSE} a list with product details will be returned.
}
\description{
Shows and returns detailed product information about a specific data set
(see \code{\link[ecmwfr]{wf_datasets}}).
}
\examples{
\dontrun{
   # Open description in browser
   wf_product_info(NULL, "reanalysis-era5-single-levels")

   # Return information
   info <- wf_product_info(NULL,
    "reanalysis-era5-single-levels", show = FALSE)
   names(info)
}
}
\seealso{
\code{\link[ecmwfr]{wf_datasets}}.
}
\author{
Reto Stauffer, Koen Hufkens
}
