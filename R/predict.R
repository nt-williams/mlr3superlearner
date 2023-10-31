#' Predict method for \code{mlr3superlearner} object
#'
#' @param object [\code{mlr3superlearner}]\cr
#'  An object returned from \code{mlr3superlearner()}.
#' @param newdata data [\code{data.frame}]\cr
#'  A \code{data.frame} containing predictors.
#' @param discrete [\code{logical(1)}]\cr
#'  Return the discrete Super Learner, or the ensemble Super Learner?
#' @param ... Unused.
#'
#' @return A vector of the predicted values.
#' @exportS3Method
#'
#' @seealso \code{\link{mlr3superlearner}}
#'
#' @examples
#' if (requireNamespace("ranger", quietly = TRUE)) {
#'   n <- 1e3
#'   W <- matrix(rnorm(n*3), ncol = 3)
#'   A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
#'   Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
#'   tmp <- data.frame(W, A, Y)
#'   fit <- mlr3superlearner(tmp, "Y", c("glm", "ranger"), outcome_type = "binomial")
#'   predict(fit, tmp)
#' }
predict.mlr3superlearner <- function(object, newdata, discrete = TRUE, ...) {
  if (!discrete) {
    pred <- object$metalearner$predict(
      fu_base_learners(object$base_learners,
                       as.data.frame(newdata)[, object$train_task$feature_names],
                       object$train_task)
    )
  } else {
    dSL <- names(which.min(object$risk))
    pred <- object$base_learners[[dSL]]$predict_newdata(newdata[, object$train_task$feature_names])
  }

  pred <- as.data.table(pred)

  switch(object$outcome_type,
         continuous = pred$response,
         binomial = pred$prob.1,
         multiclass = as.matrix(as.data.frame(pred)[, grep("^prob.", names(pred))]))
}
