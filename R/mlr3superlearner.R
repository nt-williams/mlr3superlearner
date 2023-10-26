#' Super Learner Algorithm
#'
#' Implementation of the Super Learner algorithm using the `mlr3` framework. By default, returning the discrete Super Learner. If using the ensemble Super Learner, The LASSO with an alpha value of 0 and a restriction on the lower limit of the coefficients is used as the meta-learner.
#'
#' @param data [\code{data.frame}]\cr
#'  A \code{data.frame} containing predictors and target variable.
#' @param target [\code{character(1)}]\cr
#'  The name of the target variable in \code{data}.
#' @param library [\code{character}]\cr
#'  A vector of algorithms to be used for prediction.
#' @param filters [\code{PipeOpsFilter}]
#' @param outcome_type [\code{character(1)}]\cr
#'  The outcome variable type.
#' @param folds [\code{numeric(1)}]\cr
#'  The number of cross-validation folds, or if \code{NULL} will be dynamically determined.
#' @param newdata [\code{list}]\cr
#'  A \code{list} of \code{data.frames} to generate predictions from.
#' @param group [\code{character(1)}]\cr
#'  Name of a grouping variable in \code{data}. Assumed to be discrete;
#'  observations in the same group are treated like a "block" of observations
#'  kept together during sample splitting.
#' @param info [\code{logical(1)}]\cr
#'  Print learner fitting information to the console.
#'
#' @return A list of class \code{mlr3superlearner}.
#'
#' @import mlr3learners
#' @importFrom stats coef
#' @importFrom mlr3pipelines po
#'
#' @export
#'
#' @examples
#' n <- 1e3
#' W <- matrix(rnorm(n*3), ncol = 3)
#' A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
#' Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
#' tmp <- data.frame(W, A, Y)
#'
#' if (requireNamespace("ranger", quietly = TRUE)) {
#'   mlr3superlearner(tmp, "Y", c("glm", "ranger"), outcome_type = "binomial")
#' }
#'
#' if (requireNamespace("glmnet", quietly = TRUE) &
#'     requireNamespace("mlr3filters", quietly = TRUE)) {
#'     filter <- mlr3pipelines::po("filter",
#'                                 filter = mlr3filters::flt(
#'                                   "selected_features",
#'                                   learner = lrn("classif.cv_glmnet")
#'                                 ), filter.nfeat = 3)
#'     mlr3superlearner(tmp, "Y", c("glm", "ranger"), filter, "binomial")
#' }
mlr3superlearner <- function(data, target, library, filters = NULL,
                             outcome_type = c("binomial", "continuous", "multiclass"),
                             folds = NULL, discrete = TRUE,
                             newdata = NULL, group = NULL, info = FALSE) {
  checkmate::assert_character(target, len = 1)

  if (is.list(filters)) {
    checkmate::assert_list(filters, types = c("PipeOp", "Graph", "NULL"),
                           null.ok = TRUE, len = length(library))
  } else {
    checkmate::assert_multi_class(filters, c("PipeOp", "Graph"), null.ok = TRUE)
  }

  checkmate::assert_number(folds, null.ok = TRUE)
  checkmate::assert_logical(discrete, len = 1)
  checkmate::assert_list(newdata, types = "list", null.ok = TRUE)

  if (info) {
    lgr::get_logger("mlr3")$set_threshold("info")
    on.exit(lgr::get_logger("mlr3")$set_threshold("warn"))
  }

  if (is.null(folds)) {
    folds <- set_folds({if (is.null(group)) nrow(data)
                          else length(unique(data[[group]]))},
                       match.arg(outcome_type), data[[target]])
  }

  ensemble <- make_base_learners(library, filters, outcome_type)

  task <- make_mlr3_task(data, target, outcome_type)

  if (!is.null(group)) {
    task$set_col_roles(group, "group")
  }

  resampling <- make_mlr3_resampling(task, folds)

  fits <- lapply(ensemble, fit_base_learner, task = task, resampling = resampling)
  ml <- make_metalearner(outcome_type)$train(po("featureunion")$train(purrr::map(fits, "task"))$output)
  wts <- ml$model$weights / sum(ml$model$weights)
  names(wts) <- sapply(fits, function(x) x$learner$id)

  sl <- list(metalearner = ml,
             base_learners = setNames(purrr::map(fits, function(x) x$learner), names(wts)),
             weights = wts,
             risk = setNames(purrr::map_dbl(fits, function(x) x$score), names(wts)),
             outcome_type = outcome_type,
             folds = folds,
             train_task = task)

  class(sl) <- "mlr3superlearner"

  if (is.null(newdata)) {
    sl$preds <- NULL
    return(sl)
  }

  sl$preds <- lapply(newdata, function(x) predict.mlr3superlearner(sl, x))
  sl
}

fit_base_learner <- function(learner, task, resampling) {
  msr_func <- ifelse(task$task_type == "regr", "regr.mse", "classif.logloss")
  pred <- resample(task, learner, resampling)$prediction()
  score <- pred$score(mlr3::msr(msr_func))
  new_task <- pred_to_task(as.data.table(pred), task, learner)
  learner$train(task)
  list(task = new_task, learner = learner, score = score)
}

#' @importFrom data.table `:=` setnames
pred_to_task = function(prds, task, learner) {
  out_task <- task$clone()
  if (!is.null(prds$truth)) prds[, truth := NULL]
  if (learner$predict_type == "prob") {
    prds[, response := NULL]
  }

  renaming = setdiff(colnames(prds), c("row_id", "row_ids"))
  if (task$task_type == "regr") newnames <- "response"
  else newnames <- renaming
  setnames(prds, renaming, sprintf("%s.%s", learner$id, newnames))

  row_id_col = intersect(colnames(prds), c("row_id", "row_ids"))
  setnames(prds, old = row_id_col, new = task$backend$primary_key)
  out_task$select(character(0))$cbind(prds)
  out_task
}

fu_base_learners <- function(ensemble, newdata, task) {
  tasks <- lapply(ensemble, function(lrn) {
    pred <- lrn$predict_newdata(newdata)
    pred_to_task(as.data.table(pred), task, lrn)
  })
  po("featureunion")$train(tasks)$output
}
