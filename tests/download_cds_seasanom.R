# -------------------------------------------------------------------
# Loading ecmwfr library, testing a set of different
# products (ECMWF public/closed, CDS ERA-5, ...)
# -------------------------------------------------------------------
library("ecmwfr")


# -------------------------------------------------------------------
# Seasonal anomaly forecasts from CDS (UKMO; monthly mean; grib)
# -------------------------------------------------------------------
message("\n[!] Seasonal anomaly forecasts from CDS (UKMO; montly mean; grib)\n")
if(!file.exists("_test_seasanom.grb")) {
    request_seasanom <- list(
                "dataset"            = "seasonal-postprocessed-single-levels",
                "format"             = "grib",
                "originating_centre" = "ukmo",
                "system"             = "13",
                "variable"           = "2m_temperature_anomaly",
                "product_type"       = "monthly_mean",
                "year"               = "2018",
                "month"              = "12",
                "leadtime_month"     = "6",
                "target"             = "_test_seasanom.grb")
    file <- cds_request(NULL, request_seasanom, transfer = TRUE, path = ".", verbose = TRUE)

    # Count number of messages in the grib file
    count <- try(as.integer(system(sprintf("grib_count %s", file), intern = TRUE)))
    if(inherits(count, "try-error")) {
        warning(sprintf("ERROR: ERA-5 single level data: count failed for \"%s\"\n", file))
    } else if (count == 0) {
        warning(sprintf("ERROR: ERA-5 single level data: no messages in file \"%s\"\n", file))
    } else {
        message("grib file readable, contains ", count," messages, all fine.")
    }
}


# No NetCDF option available.
