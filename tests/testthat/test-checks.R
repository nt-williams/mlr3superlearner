n <- 50
W <- matrix(rnorm(n*3), ncol = 3)
A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
tmp <- data.frame(W, A, Y)

test_that("All initial checks invoke errors", {
  expect_error(mlr3superlearner(tmp, c("Y", "Y1"), c("mean"), "binomial"))
  expect_error(mlr3superlearner(tmp, c("Y"), c("mean"), "binomial", folds = "hello"))
  expect_error(mlr3superlearner(tmp, "Y", c("mean"), "binomial", discrete = "yes"))
  expect_error(mlr3superlearner(tmp, "Y", c("mean"), "binomial", newdata = tmp))
})
