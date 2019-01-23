# -------------------------------------------------------------------
# Loading ecmwfr library, testing a set of different
# products (ECMWF public/closed, CDS ERA-5, ...)
# -------------------------------------------------------------------
library("ecmwfr")


# -------------------------------------------------------------------
# Satellite based soil moisture, monthly mean (NetCDF).
# Note: even if you specify zip (as shown on the CDS interface)
# it seems to return a NetCDF file).
# -------------------------------------------------------------------
message("\n[!] Satellite based soil moisture, monthly mean (zip)\n")
if(!file.exists("_test_soilmoisture.nc")) {
    request_soil <- list(
                "dataset"          = "satellite-soil-moisture",
                "format"           = "zip",
                "variable"         = "soil_moisture_saturation",
                "time_aggregation" = "month_average",
                "year"             = "2018",
                "month"            = "10",
                "day"              = "01",
                "type_of_sensor"   = "active",
                "type_of_record"   = "icdr",
                "version"          = "v201706.0.0",
                "target"           = "_test_soilmoisture.nc")
    file <- cds_request(NULL, request_soil, transfer = TRUE, path = ".", verbose = TRUE)

    # Test if we can open the NetCDF file
    tmp <- try(ncdf4::nc_open(file))
    if(inherits(tmp, "try-error")) {
        warning(sprintf("ERROR: Satellite soil moisture data: cannot open NetCDF file \"%s\"\n", file))
    } else {
        ncdf4::nc_close(tmp)
        message("NetCDF file readable, all fine.")
    }
}


