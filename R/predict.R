#' Predict method for \code{mlr3superlearner} object
#'
#' @param object An object returned from \code{mlr3superlearner()}.
#' @param newdata A \code{data.frame} to return predictions from.
#' @param ... Unused.
#'
#' @return Predicted values.
#' @exportS3Method
#'
#' @seealso \code{\link{mlr3superlearner}}
predict.mlr3superlearner <- function(object, newdata, ...) {
  .f <- ifelse(object$outcome_type == "continuous",
               function(x, data) x$predict_newdata(data)$response,
               function(x, data) x$predict_newdata(data)$prob[, "1"])
  if (object$discrete) {
    out <- .f(object$learners[[1]], newdata[, object$x, drop = F])
    return(out)
  }
  z <- lapply(object$learners, .f, newdata[, object$x, drop = F])
  z <- matrix(Reduce(`c`, z), ncol = length(object$learners))
  colnames(z) <- unlist(lapply(object$learners, function(x) x$id))
  weights <- object$weights
  use <- names(weights[weights != 0])
  crossprod(t(z[, use, drop = FALSE]), weights[use])[, 1]
}
