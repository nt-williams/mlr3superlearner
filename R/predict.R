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
  .f <- ifelse(object$outcome_type == "continuous",
               function(x, data) x$predict_newdata(data)$response,
               function(x, data) x$predict_newdata(data)$prob[, "1"])

  z <- lapply(object$learners, .f, newdata[, object$x, drop = F])
  z <- matrix(Reduce(`c`, z), ncol = length(object$learners))
  colnames(z) <- names(object$learners)

  .f(object$metalearner, as.data.frame(z))
}
