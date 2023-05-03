#' Super Learner Algorithm
#'
#' Implementation of the Super Learner algorithm using the `mlr3` framework.
#'
#' @param data A \code{data.frame} containing predictors and target variable.
#' @param target The name of the target variable in \code{data}.
#' @param library A vector of algorithms to be used for prediction.
#' @param outcome_type The outcome variable type.
#' @param folds The number of cross-validation folds.
#' @param newdata A \code{list} of \code{data.frames} to generate predictions from.
#'
#' @return A list of class \code{mlr3superlearner}.
#' @export
#'
#' @examples
#' library(mlr3superlearner)
#' n <- 1e3
#' W <- matrix(rnorm(n*3), ncol = 3)
#' A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
#' Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
#' tmp <- data.frame(W, A, Y)
#' fit <- mlr3superlearner(tmp, "Y", c("glm", "glmnet"), "binomial")
#' predict(fit, tmp)
mlr3superlearner <- function(data, target, library,
                             outcome_type = c("binomial", "continuous"),
                             folds = 10L, newdata = NULL) {
  checkmate::assert_character(target)
  checkmate::assert_number(folds)

  resampling <- mlr3::rsmp("cv", folds = folds)
  task <- make_mlr3_task(data, target, outcome_type)
  ensemble <- make_base_learners(library, outcome_type)

  weights <- compute_super_learner_weights(
    lapply(ensemble, function(algo) mlr3::resample(task, algo, resampling)),
    y = data[[target]],
    outcome_type
  )

  ensemble <- lapply(ensemble, function(algo) algo$train(task))
  sl <- list(learners = ensemble, weights = weights, outcome_type = outcome_type, folds = folds,
             x = setdiff(names(data), target))
  class(sl) <- "mlr3superlearner"

  if (is.null(newdata)) {
    sl$preds <- NULL
    return(sl)
  }

  sl$preds <- lapply(newdata, function(x) predict.mlr3superlearner(sl, x))
  sl
}

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
               function(x) x$predict_newdata(newdata[, object$x])$response,
               function(x) x$predict_newdata(newdata[, object$x])$prob[, "1"])
  z <- lapply(object$learners, .f)
  z <- matrix(Reduce(`c`, z), ncol = length(object$learners))
  SuperLearner::method.NNLS()$computePred(z, object$weights$coef)[, 1]
}

make_mlr3_task <- function(data, target, outcome_type) {
  if (outcome_type == "binomial") {
    task <- mlr3::as_task_classif(data,
                                  target = target,
                                  id = "mlr3superlearner_training_task")
    return(task)
  }

  mlr3::as_task_regr(data,
                     target = target,
                     id = "mlr3superlearner_training_task")
}

make_base_learners <- function(library, outcome_type) {
  predicate <- ifelse(outcome_type == "binomial", "classif", "regr")
  if (predicate == "classif") {
    return(mlr3::lrns(glue::glue("classif.{lookup_algos(library, 'classif')}"), predict_type = "prob"))
  }
  mlr3::lrns(glue::glue("regr.{lookup_algos(library, 'regr')}"))
}

compute_super_learner_weights <- function(learners, y, outcome_type) {
  x <- lapply(learners,
              function(x) {
                preds <- data.table::as.data.table(x$prediction())
                preds[order(preds$row_ids), ifelse(outcome_type == "continuous", "response", "prob.1")]
              })
  x <- matrix(Reduce(`c`, x), ncol = length(learners))
  ids <- unlist(lapply(learners, function(x) x$learner$id))
  SuperLearner::method.NNLS()$computeCoef(x, y, ids, FALSE, 1)
}
