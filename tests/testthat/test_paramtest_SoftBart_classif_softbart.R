test_that("classif.softbart train", {
  learner = lrn("classif.softbart")
  fun = SoftBart::softbart_probit
  exclude = c(
    "object", # handled internally
    "data" # handled internally
  )

  # note that you can also pass a list of functions in case $.train calls more than one
  # function, e.g. for control arguments
  paramtest = run_paramtest(learner, fun, exclude, tag = "train")
  expect_paramtest(paramtest)
})

test_that("classif.softbart predict", {
  learner = lrn("classif.softbart")
  fun = SoftBart::predict # nolint
  exclude = c(
    "object", # handled internally
    "data", # handled internally
    "newdata" # handled internally
  )

  paramtest = run_paramtest(learner, fun, exclude, tag = "predict")
  expect_paramtest(paramtest)
})
