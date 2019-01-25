# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

# format request (see below)
cds_request <- list(
              "dataset"        = "reanalysis-era5-pressure-levels",
              "product_type"   = "reanalysis",
              "format"         = "netcdf",
              "variable"       = "temperature",
              "pressure_level" = "850",
              "year"           = "2000",
              "month"          = "04",
              "day"            = "04",
              "time"           = "00:00",
              "area"           = "70/-10/30/40",
              "format"         = "netcdf",
              "target"         = "era5-demo.nc")

# set password using encrypted key
# if provided, otherwise just continue
# assuming a valid keychain value (see
# additional check below)
key <- system("echo $CDS", intern = TRUE)
if(key != "" & key != "$CDS"){
  wf_set_key(user = "2088",
             key = system("echo $CDS", intern = TRUE))
}
rm(key)

# Check if a password is not set. This traps the inconsistent
# behavious between systems while accomodating for encrypted
# keys on Travis CI. Mostly this deals with the sandboxed
# checks on linux which can't access the global keychain or
# environmental variables (hence fail to retrieve the api key).
# This also allows for very basic checks on r-hub.
# No checks should be skiped on either Travis CI or OSX.
skip_check <- try(wf_get_key(user = "2088"))
skip_check <- inherits(skip_check, "try-error")

test_that("cds datasets returns data.frame or list", {
  skip_if(skip_check)
    expect_true(inherits(wf_datasets(user = "2088",
                                     service = "cds",
                                     simplify = TRUE), "data.frame"))
    expect_true(inherits(wf_datasets(user = "2088",
                                     service = "cds",
                                     simplify = FALSE), "list"))
})

# Testing the cds request function
test_that("cds request", {
  skip_if(skip_check)
    tmp <- wf_request(user = "2088",
                      request = cds_request,
                      transfer = TRUE)

    expect_true(inherits(tmp, "character"))
    expect_true(file.exists(tmp))
    expect_true(inherits(wf_request(user = "2088",
                request = cds_request,
                transfer = FALSE), "list"))
})

# # Expecting error if required arguments are not set:
 test_that("required arguments missing for cds_* functions", {
   skip_if(skip_check)
     # CDS dataset (requires at least 'user')
     expect_error(wf_dataset())

     # CDS productinfo (requires at least 'user' and 'dataset')
     expect_error(wf_product_info())
     expect_error(wf_product_info(user = "2088",
                                  service = "cds",
                                  dataset = "foo"))

     # CDS productinfo: product name which is not available
     expect_output(str(wf_product_info(user = "2088",
                                       service = "cds",
                                       dataset = "satellite-methane")))

     # CDS tranfer (forwarded to wf_transfer, requires at least
     # 'user' and 'url)
     expect_error(wf_transfer())
     expect_error(wf_transfer(user = "2088",
                              service = "cds",
                              url = "http://google.com"))
     # CDS transfer with wrong type
     expect_error(wf_transfer(user = "2088",
                              url = "http://google.com",
                              service = "foo"))
})
