#' @exportS3Method
print.mlr3superlearner <- function(object, ...) {
  print(cbind(Risk = object$risk,
              Coefficients = object$weights))
}
