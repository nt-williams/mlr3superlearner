#' Predict method for \code{mlr3superlearner} object
#'
#' @param object An object returned from \code{mlr3superlearner()}.
#' @param newdata A \code{data.frame} to return predictions from.
#'
#' @return Predicted values.
#' @exportS3Method
#'
#' @seealso \code{\link{mlr3superlearner}}
predict.mlr3superlearner <- function(object, newdata) {
  task <- make_mlr3_task(newdata, object$formula, NULL, object$outcome_type)
  .f <- ifelse(object$outcome_type == "continuous",
               function(x) x$predict(task)$response,
               function(x) x$predict(task)$prob[, "1"])
  z <- lapply(object$learners, .f)
  z <- matrix(Reduce(`c`, z), ncol = length(object$learners))
  # predict_nnls(z, object$weights$coef)
  predict_CC_LS(z, object$weights$coef)
}
