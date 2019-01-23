# -------------------------------------------------------------------
# Loading ecmwfr library, testing a set of different
# products (ECMWF public/closed, CDS ERA-5, ...)
# -------------------------------------------------------------------
library("ecmwfr")


# -------------------------------------------------------------------
# ERA-5 reanalysis, CDS data server, pressure level data, NetCDF
# -------------------------------------------------------------------
message("\n[!] Testing ERA-5 reanalysis, CDS, pressure level data, NetCDF.\n")
if(!file.exists("_test_era5_pl.nc")) {
    request_era_pl <- list(
                "dataset"        = "reanalysis-era5-pressure-levels",
                "product_type"   = "reanalysis",
                "variable"       = "temperature",
                "pressure_level" = "850",
                "year"   = "1983",
                "month"  = "05",
                "day"    = "07",
                "time"   = sprintf("%02d", 0:23),
                "area"   = "47/10/46/11",
                "format" = "netcdf",
                "target" = "_test_era5_pl.nc")
    file <- cds_request(NULL, request_era_pl, transfer = TRUE, path = ".", verbose = TRUE)

    # Test if we can open the NetCDF file
    tmp <- try(ncdf4::nc_open(file))
    if(inherits(tmp, "try-error")) {
        warning(sprintf("ERROR: ERA-5 pressure level data: cannot open NetCDF file \"%s\"\n", file))
    } else {
        ncdf4::nc_close(tmp)
        message("NetCDF file readable, all fine.")
    }
}


# -------------------------------------------------------------------
# ERA-5 reanalysis, CDS data server, single level data (surface data), NetCDF
# -------------------------------------------------------------------
message("\n[!] Testing ERA-5 reanalysis, CDS, single level data, NetCDF.\n")
if(!file.exists("_test_era5_sf.nc")) {
    request_era_sf <- list(
                "dataset"        = "reanalysis-era5-single-levels",
                "product_type"   = "reanalysis",
                "variable"       = "2m_temperature",
                "year"   = "1983",
                "month"  = "02",
                "day"    = "10",
                "time"   = sprintf("%02d", 0:23),
                "area"   = "47/10/46/11",
                "format" = "netcdf",
                "target" = "_test_era5_sf.nc")
    file <- cds_request(NULL, request_era_sf, transfer = TRUE, path = ".", verbose = TRUE)

    # Test if we can open the NetCDF file
    tmp <- try(ncdf4::nc_open(file))
    if(inherits(tmp, "try-error")) {
        warning(sprintf("ERROR: ERA-5 surface level data: cannot open NetCDF file \"%s\"\n", file))
    } else {
        ncdf4::nc_close(tmp)
        message("NetCDF file readable, all fine.")
    }
}


# -------------------------------------------------------------------
# ERA-5 reanalysis, CDS data server, pressure level data, grib1
# -------------------------------------------------------------------
message("\n[!] Testing ERA-5 reanalysis, CDS, pressure level data, grib1.\n")
if(!file.exists("_test_era5_pl.grb")) {
    request_era_pl <- list(
                "dataset"        = "reanalysis-era5-pressure-levels",
                "product_type"   = "reanalysis",
                "variable"       = "temperature",
                "pressure_level" = "850",
                "year"   = "1983",
                "month"  = "03",
                "day"    = "07",
                "time"   = sprintf("%02d", 0:23),
                "area"   = "47/10/46/11",
                "format" = "grib",
                "target" = "_test_era5_pl.grb")
    file <- cds_request(NULL, request_era_pl, transfer = TRUE, path = ".", verbose = TRUE)

    # Count number of messages in the grib file
    count <- try(as.integer(system(sprintf("grib_count %s", file), intern = TRUE)))
    if(inherits(count, "try-error")) {
        warning(sprintf("ERROR: ERA-5 pressure level data: count failed for \"%s\"\n", file))
    } else if (count == 0) {
        warning(sprintf("ERROR: ERA-5 pressure level data: no messages in file \"%s\"\n", file))
    } else {
        message("grib file readable, contains ", count," messages, all fine.")
    }
}


# -------------------------------------------------------------------
# ERA-5 reanalysis, CDS data server, single level data (surface data), grib1
# -------------------------------------------------------------------
message("\n[!] Testing ERA-5 reanalysis, CDS, single level data, grib1.\n")
if(!file.exists("_test_era5_sf.grb")) {
    request_era_sf <- list(
                "dataset"        = "reanalysis-era5-single-levels",
                "product_type"   = "reanalysis",
                "variable"       = "2m_temperature",
                "year"   = "1983",
                "month"  = "03",
                "day"    = "07",
                "time"   = sprintf("%02d", 0:23),
                "area"   = "47/10/46/11",
                "format" = "grib",
                "target" = "_test_era5_sf.grb")
    file <- cds_request(NULL, request_era_sf, transfer = TRUE, path = ".", verbose = TRUE)

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


