# -------------------------------------------------------------------
# Loading ecmwfr library, testing a set of different
# products (ECMWF public/closed, CDS ERA-5, ...)
# -------------------------------------------------------------------
library("ecmwfr")


# -------------------------------------------------------------------
# ECMWF IFS Forecasts (requires member state/commercial user account!)
# -------------------------------------------------------------------
message("\n[!] Testing ECMWF IFS 00 UTC run, NetCDF (requires member state login)\n")
if(!file.exists("_test_ecmwf_ifs_sf.nc")) {
    request_ifs_sf <- list(
                "dataset"  = "mars",
                "class"    = "od",
                "date"     = strftime(Sys.Date()-1, "%Y-%m-%d"),
                "expver"   = "1",
                "levtype"  = "sfc",
                "param"    = "167.128",    # 2m temperature
                "step"     = "3",          # forecast step +3h
                "stream"   = "oper",
                "time"     = "00:00:00",   # 00 UTC run
                "type"     = "fc",
                "grid"     = "0.5/0.5",    # 0.5 degree grid
                "format"   = "netcdf",     # NetCDF
                "area"     = "50/0/40/10", # custom subset
                "target"   = "_ecmwf_ifs_sf.nc")

    file <- wf_request(NULL, request = request_ifs_sf, transfer = TRUE, path = ".", verbose = TRUE)
    print(file)

    # Test if we can open the NetCDF file
    tmp <- try(ncdf4::nc_open(file))
    if(inherits(tmp, "try-error")) {
        warning(sprintf("ERROR: ECMWF IFS surface level data: cannot open NetCDF file \"%s\"\n", file))
    } else {
        ncdf4::nc_close(tmp)
        message("NetCDF file readable, all fine.")
    }
}

# -------------------------------------------------------------------
# ECMWF IFS Forecasts (requires member state/commercial user account!)
# -------------------------------------------------------------------
message("\n[!] Testing ECMWF IFS 00 UTC run, grib1 (requires member state login)\n")
if(!file.exists("_test_ecmwf_ifs_sf.grb")) {
    request_ifs_sf <- list(
                "dataset"  = "mars",
                "class"    = "od",
                "date"     = strftime(Sys.Date()-1, "%Y-%m-%d"),
                "expver"   = "1",
                "levtype"  = "sfc",
                "param"    = "167.128",    # 2m temperature
                "step"     = "3",          # forecast step +3h
                "stream"   = "oper",
                "time"     = "00:00:00",   # 00 UTC run
                "type"     = "fc",
                "grid"     = "0.5/0.5",    # 0.5 degree grid
                "format"   = "grib",       # grib 1
                "area"     = "50/0/30/20", # custom subset
                "target"   = "ecmwf_ifs_sf.grb")

    file <- wf_request(NULL, request = request_ifs_sf, transfer = TRUE, path = ".", verbose = TRUE)

    # Count number of messages in the grib file
    count <- try(as.integer(system(sprintf("grib_count %s", file), intern = TRUE)))
    if(inherits(count, "try-error")) {
        warning(sprintf("ERROR: ECMWF IFS: count failed for \"%s\"\n", file))
    } else if (count == 0) {
        warning(sprintf("ERROR: ECMWF IFS: no messages in file \"%s\"\n", file))
    } else {
        message("grib file readable, contains ", count," messages, all fine.")
    }
}
