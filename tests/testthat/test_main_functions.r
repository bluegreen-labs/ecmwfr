# test functions without parameters
# only can fail upon server error
test_that("test wf_set_key()",{

  expect_silent(
    wf_set_key(email = "john.smith@example.com",
               key = "XXXXXXXXXXXXXXXXXXXXXX")
  )

  expect_error(
    wf_set_key(key = "XXXXXXXXXXXXXXXXXXXXXX")
  )

})

test_that("test wf_get_key()",{

  expect_silent(
    wf_get_key(email = "john.smith@example.com")
  )

  expect_error(
    wf_get_key()
  )

})
