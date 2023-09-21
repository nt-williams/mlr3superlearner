#' @exportS3Method
print.mlr3superlearner <- function(x, ...) {
  d <- cli::cli_div(theme = list(rule = list("line-type" = "double")))
  cli::cli_rule(left = "{.fn mlr3superlearner}")
  cli::cli_end(d)
  print(cbind(Risk = x$risk,
              Coefficients = x$weights))
}
