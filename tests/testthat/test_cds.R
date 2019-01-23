# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

# format request (see below)
request_pl <- list(
              "dataset"        = "reanalysis-era5-pressure-levels",
              "product_type"   = "reanalysis",
              "format"         = "netcdf",
              "variable"       = "temperature",
              "pressure_level" = "850",
              "year"           = "2000",
              "month"          = "04",
              "day"            = "04",
              "time"           = "00:00",
              "area"           = "70/-20/00/60",
              "format"         = "netcdf",
              "target"         = "era5-demo.nc")
request_sf <- list(
              "dataset"        = "reanalysis-era5-single-levels",
              "product_type"   = "reanalysis",
              "format"         = "netcdf",
              "variable"       = "total_precipitation",
              "year"           = "2000",
              "month"          = "04",
              "day"            = "04",
              "time"           = "00:00",
              "area"           = "70/-20/00/60",
              "format"         = "netcdf",
              "target"         = "era5-demo.nc")


# Test if we get the correct key
test_that("retrieve key via cds_get_key", {
    cds_set_key(Sys.getenv("CDSAPIUSER"), Sys.getenv("CDSAPIKEY"))
    # Expect to get the very same argument
    expect_identical(Sys.getenv("CDSAPIKEY"), cds_get_key(Sys.getenv("CDSAPIUSER")))
})

# Test if we get the expected information from the .cdsapirc file
test_that("retrieve cds login information via .cdsapirc file", {
    tmp <- cds_key_from_file()
    # cds_key_from_file should return a list
    expect_type(tmp, "list")
    # Check list elements (CDS login information)
    expect_identical(Sys.getenv("CDSAPIUSER"), tmp$user)
    expect_identical(Sys.getenv("CDSAPIUSER"), tmp$email)
    expect_identical(Sys.getenv("CDSAPIKEY"), tmp$key)
})

# cds_set_key should be silent
test_that("set key via cds_set_key", {
    expect_silent(cds_set_key(Sys.getenv("CDSAPIUSER"), Sys.getenv("CDSAPIKEY")))
})

test_that("cds datasets returns data.frame or list", {
    # If simplify = TRUE: data.frame
    expect_true(inherits(cds_datasets(user = NULL, simplify = TRUE), "data.frame"))
    # If simplify = FALSE: list
    expect_true(inherits(cds_datasets(user = NULL, simplify = FALSE), "list"))
})

# Expecting error if required arguments are not set:
test_that("required arguments missing for cds_* functions", {
    # CDS dataset (requires at least 'user')
    expect_error(cds_dataset())
    # CDS retrieve (requires at least 'user' and 'request')
    expect_error(cds_retrieve())
    expect_error(cds_retrieve("foo"))
    expect_error(cds_retrieve(request = list()))
    # CDS productinfo (requires at least 'user' and 'dataset')
    expect_error(cds_productinfo())
    expect_error(cds_productinfo(dataset = "foo"))
    # CDS productinfo: product name which is not available
    expect_error(cds_productinfo(dataset = "dummy-product-name"))
    # CDS tranfer (forwarded to wf_transfer, requires at least
    # 'user' and 'url)
    expect_error(cds_transfer())
    expect_error(cds_transfer(url = "http://google.com"))
    # CDS transfer with wrong type
    expect_error(cds_transfer(NULL, "http://google.com", type = "foo"))
})

# Testing the cds request function
test_that("cds request", {
    # With transfer: returns name of the final file
    tmp <- cds_request(NULL, request_pl, transfer = TRUE)
    expect_true(inherits(tmp, "character"))
    # Check if output file exists
    expect_true(file.exists(tmp))
    # Without transfer: returns a list
    expect_true(inherits(cds_request(NULL, request_pl, transfer = FALSE), "list"))
})

##test_that("test request (transfer) function", {
##  skip_if(skip_check)
##  expect_message(wf_request(
##    email = "khrdev@outlook.com",
##    transfer = TRUE,
##    request = my_request,
##    time_out = 60))
##})
##
##test_that("test request (transfer) function - time out", {
##  skip_if(skip_check)
##  expect_output(str(wf_request(
##    email = "khrdev@outlook.com",
##    transfer = TRUE,
##    request = my_request,
##    time_out = 1)))
##})
##
##test_that("test request (transfer) function - no transfer", {
##  skip_if(skip_check)
##  ct <- wf_request(
##    email = "khrdev@outlook.com",
##    transfer = FALSE,
##    request = my_request)
##
##  expect_output(str(ct))
##  expect_message(wf_delete(email = "khrdev@outlook.com",
##                           url = ct$href))
##})
##
##test_that("test request (transfer) function - no email", {
##  expect_error(wf_request())
##})
##
##test_that("test transfer function - no login", {
##  expect_error(wf_transfer())
##})
##
##test_that("test request (transfer) function", {
##  skip_if(skip_check)
##  expect_message(wf_request(
##    email = "khrdev@outlook.com",
##    transfer = TRUE,
##    request = my_request,
##    time_out = 60))
##})
##
##test_that("test delete function - no login", {
##  expect_error(wf_delete())
##})
