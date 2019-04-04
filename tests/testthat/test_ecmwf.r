# set options
opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

# format request (see below)
my_request <- list(stream = "oper",
                   levtype = "sfc",
                   param = "165.128",
                   dataset = "interim",
                   step = "0",
                   grid = "0.75/0.75",
                   time = "00",
                   date = "2014-07-01/to/2014-07-31",
                   type = "an",
                   class = "ei",
                   area = "51/0/50/1",
                   format = "netcdf",
                   target = "tmp.nc")

# set password using encrypted key
# if provided, otherwise just continue
# assuming a valid keychain value (see
# additional check below)
key <- system("echo $KEY", intern = TRUE)
if(key != "" & key != "$KEY"){
  wf_set_key(user = "khrdev@outlook.com",
             key = system("echo $KEY", intern = TRUE),
             service = "webapi")
}
rm(key)

# Check if a password is not set. This traps the inconsistent
# behavious between systems while accomodating for encrypted
# keys on Travis CI. Mostly this deals with the sandboxed
# checks on linux which can't access the global keychain or
# environmental variables (hence fail to retrieve the api key).
# This also allows for very basic checks on r-hub.
# No checks should be skiped on either Travis CI or OSX.
login_check <- try(wf_get_key(user = "khrdev@outlook.com"), silent = TRUE)
login_check <- inherits(login_check, "try-error")
server_check <- !ecmwf_running(wf_server(service = "webapi"))

test_that("set, get secret key",{
  skip_if(login_check)
  skip_if(server_check)

  # check retrieval
  expect_output(str(wf_get_key(user = "khrdev@outlook.com")))

  # failed set keys commands
  expect_error(wf_set_key(key = "XXXX",
             service = "webapi"))
  expect_error(wf_set_key(user = "khrdev@outlook.com",
             service = "webapi"))
  expect_error(wf_set_key(user = "khrdev@outlook.com"))
})

test_that("test dataset function", {
  skip_if(login_check)
  skip_if(server_check)
  expect_output(str(wf_datasets(user = "khrdev@outlook.com")))
})

test_that("test dataset function - no login", {
  expect_error(wf_datasets())
})

test_that("list datasets webapi",{
  skip_if(login_check)
  skip_if(server_check)
  expect_output(str(wf_datasets(user = "khrdev@outlook.com",
                                service = "webapi")))
})

test_that("test services function", {
  skip_if(login_check)
  skip_if(server_check)
  expect_output(str(wf_services(user = "khrdev@outlook.com")))
})

test_that("test services function - no login", {
  expect_error(wf_services())
})

test_that("test user info function", {
  skip_if(login_check)
  skip_if(server_check)
  expect_output(str(wf_user_info(user = "khrdev@outlook.com")))
})

test_that("test user info function - no login", {
  expect_error(wf_user_info())
})

test_that("test request (transfer) function", {
  skip_if(login_check)
  skip_if(server_check)
  expect_message(wf_request(
    user = "khrdev@outlook.com",
    transfer = TRUE,
    request = my_request,
    time_out = 60))
})

test_that("test request (transfer) function - time out", {
  skip_if(login_check)
  skip_if(server_check)
  expect_output(str(wf_request(
    user = "khrdev@outlook.com",
    transfer = TRUE,
    request = my_request,
    time_out = 1)))
})

test_that("test request (transfer) function - no transfer", {
  skip_if(login_check)
  skip_if(server_check)
  ct <- wf_request(
    user = "khrdev@outlook.com",
    transfer = FALSE,
    request = my_request)

  ct2 <- wf_request(
    user = "khrdev@outlook.com",
    transfer = FALSE,
    request = my_request)


  expect_output(str(ct))
  expect_message(wf_delete(user = "khrdev@outlook.com",
                           url = ct$href))
  expect_silent(wf_delete(user = "khrdev@outlook.com",
                           url = ct2$href,
                           verbose = FALSE))
})

test_that("test request (transfer) function - no email", {
  expect_error(wf_request())
})

test_that("test transfer function - no login", {
  expect_error(wf_transfer())
})

test_that("list datasets webapi",{
  skip_if(login_check)
  skip_if(server_check)
  expect_output(str(wf_datasets(user = "khrdev@outlook.com",
                                service = "webapi")))
  expect_output(str(wf_datasets(user = "khrdev@outlook.com",
                                service = "webapi",
                                simplify = FALSE)))
})

test_that("test request (transfer) function", {
  skip_if(login_check)
  skip_if(server_check)
  expect_message(
    wf_request(
    user = "khrdev@outlook.com",
    transfer = TRUE,
    request = my_request,
    time_out = 180)
    )
})

# webapi product info
test_that("check product info",{
  expect_output(str(
    wf_product_info(dataset = "interim",
                    user = "khrdev@outlook.com",
                    service = "webapi",
                    simplify = FALSE)))
})

test_that("test delete function - no login", {
  expect_error(wf_delete())
})

test_that("test request (transfer) function - larger download", {
  skip_if(login_check)
  skip_if(server_check)

  # large request
  large_request <- list(stream = "oper",
                 levtype = "sfc",
                 param = "167.128",
                 dataset = "interim",
                 step = "0",
                 grid = "0.75/0.75",
                 time = "00",
                 date = "2014-07-01/to/2015-07-02",
                 type = "an",
                 class = "ei",
                 area = "50/10/61/21",
                 format = "netcdf",
                 target = "tmp.nc")

  expect_message(wf_request(
    user = "khrdev@outlook.com",
    transfer = TRUE,
    request = large_request,
    time_out = 300))
})

test_that("check request - no dataset field", {
  my_request <- list(stream = "oper",
                        levtype = "sfc",
                        param = "167.128",
                        step = "0",
                        grid = "0.75/0.75",
                        time = "00",
                        date = "2014-07-01/to/2015-07-02",
                        type = "an",
                        class = "ei",
                        area = "50/10/61/21",
                        format = "netcdf")
  expect_error(
    wf_check_request(
      user = "khrdev@outlook.com",
      request = my_request)
  )
})

test_that("check request - bad request type", {
  my_request <- "xyz"
  expect_error(
    wf_check_request(
      user = "khrdev@outlook.com",
      request = my_request)
  )
})

test_that("check mars request - no target", {
  my_request <- list(stream = "oper",
                        levtype = "sfc",
                        param = "167.128",
                        dataset = "mars",
                        step = "0",
                        grid = "0.75/0.75",
                        time = "00",
                        date = "2014-07-01/to/2015-07-02",
                        type = "an",
                        class = "ei",
                        area = "50/10/61/21",
                        format = "netcdf")
  expect_error(
    wf_check_request(
      user = "khrdev@outlook.com",
      request = my_request)
  )
})

test_that("check request - no netcdf grid specified", {
  my_request <- list(stream = "oper",
                        levtype = "sfc",
                        param = "167.128",
                        dataset = "mars",
                        step = "0",
                        time = "00",
                        date = "2014-07-01/to/2015-07-02",
                        type = "an",
                        class = "ei",
                        area = "50/10/61/21",
                        format = "netcdf")
  expect_error(
    wf_check_request(
      user = "khrdev@outlook.com",
      request = my_request)
  )
})

test_that("check request - bad credentials", {
  skip_if(server_check)
  my_request <- list(stream = "oper",
                        levtype = "sfc",
                        param = "167.128",
                        dataset = "interim",
                        step = "0",
                        grid = "0.75/0.75",
                        time = "00",
                        date = "2014-07-01/to/2015-07-02",
                        type = "an",
                        class = "ei",
                        area = "50/10/61/21",
                        format = "netcdf",
                        target = "tmp.nc")
  expect_error(
    wf_check_request(
      user = "zzz@zzz.zzz",
      request = my_request)
  )
})
