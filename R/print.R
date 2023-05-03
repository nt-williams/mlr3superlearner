#' @exportS3Method
print.mlr3superlearner <- function(object, ...) {
  print(cbind(Risk = object$weights$cvRisk, Coef = object$weights$coef))
}
