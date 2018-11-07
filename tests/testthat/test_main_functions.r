# test functions without parameters
# only can fail upon server error

opts <- options(keyring_warn_for_env_fallback = FALSE)
on.exit(options(opts), add = TRUE)

test_that("set, get", {

  skip_on_cran()

  service <- random_service()
  username <- random_username()
  password <- random_password()

  expect_silent(wf_set_key(username, password))
  expect_equal(wf_get_key(username), password)
})

