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
#' @param outcome_type [\code{character(1)}]\cr
#'  The outcome variable type.
#' @param folds [\code{numeric(1)}]\cr
#'  The number of cross-validation folds, or if \code{NULL} will be dynamically determined.
#' @param discrete [\code{logical(1)}]\cr
#'  Return the discrete Super Learner, or the ensemble Super Learner?
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
#'
#' @export
#'
#' @examples
#' library(mlr3superlearner)
#' n <- 1e3
#' W <- matrix(rnorm(n*3), ncol = 3)
#' A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
#' Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
#' tmp <- data.frame(W, A, Y)
#' fit <- mlr3superlearner(tmp, "Y", c("glm", "cv_glmnet", "ranger"), "binomial")
#' predict(fit, tmp)
mlr3superlearner <- function(data, target, library,
                             outcome_type = c("binomial", "continuous"),
                             folds = NULL, discrete = TRUE,
                             newdata = NULL, group = NULL, info = FALSE) {
  checkmate::assert_character(target, len = 1)
  # checkmate::assert_character(library)
  checkmate::assert_number(folds, null.ok = TRUE)
  checkmate::assert_logical(discrete, len = 1)
  checkmate::assert_list(newdata, types = "list", null.ok = TRUE)

  ensemble <- make_base_learners(library, outcome_type)

  if (info) {
    lgr::get_logger("mlr3")$set_threshold("info")
    on.exit(lgr::get_logger("mlr3")$set_threshold("warn"))
  }

  if (is.null(folds)) {
    folds <- set_folds(nrow(data), match.arg(outcome_type), data[[target]])
  }

  task <- make_mlr3_task(data, target, outcome_type)

  if (!is.null(group)) {
    task$set_col_roles(group, "group")
  }

  resampling <- make_mlr3_resampling(task, folds)

  meta <- compute_super_learner_weights(
    lapply(ensemble, function(algo) mlr3::resample(task, algo, resampling)),
    y = data[[target]],
    outcome_type
  )

  if (length(library) == 1 || discrete) {
    weights <- vector("numeric", length(library))
    names(weights) <- unlist(lapply(ensemble, function(x) x$id))
    is_discrete <- which.min(meta$risk)
    weights[is_discrete] <- 1
    ensemble <- lapply(ensemble[is_discrete], function(algo) algo$train(task))
    meta$metalearner <- NULL
  } else {
    ensemble <- lapply(ensemble, function(algo) algo$train(task))
    weights <- as.matrix(coef(meta$metalearner$model))
    weights <- weights[rownames(weights) %in% unlist(lapply(ensemble, function(x) x$id)), 1]
    weights <- weights / sum(weights)
  }

  sl <- list(learners = ensemble,
             metalearner = meta$metalearner,
             weights = weights[order(names(weights))],
             risk = meta$risk[order(names(meta$risk))],
             outcome_type = outcome_type,
             folds = folds,
             x = setdiff(names(data), target),
             discrete = discrete)

  class(sl) <- "mlr3superlearner"

  if (is.null(newdata)) {
    sl$preds <- NULL
    return(sl)
  }

  sl$preds <- lapply(newdata, function(x) predict.mlr3superlearner(sl, x))
  sl
}

#' @importFrom mlr3 as_task_classif
#' @importFrom mlr3 as_task_regr
make_mlr3_task <- function(data, target, outcome_type) {
  args <- list(x = data,
               target = target,
               id = "mlr3superlearner_training_task")

  switch(outcome_type,
         binomial = do.call(as_task_classif, args),
         continuous = do.call(as_task_regr, args))
}

make_base_learners <- function(library, outcome_type) {
  if (is.list(library)) {
    has_necessary_packages(purrr::map_chr(library, 1), outcome_type)

    stack <- lapply(library, function(info) {
      args <- as.list(info)[-1]
      args$.key <- lookup(info[[1]], outcome_type)
      args$id <- make_learner_id(info, outcome_type)
      if (outcome_type == "binomial") args$predict_type <- "prob"

      do.call(mlr3::lrn, args)
    })
  } else {
    has_necessary_packages(library, outcome_type)

    args <- list(.keys = lookup(library, outcome_type))
    if (outcome_type == "binomial") args$predict_type <- "prob"
    stack <- do.call(mlr3::lrns, args)
  }

  stack
}

compute_super_learner_weights <- function(learners, y, outcome_type) {
  x <- lapply(learners,
              function(x) {
                preds <- data.table::as.data.table(x$prediction())
                preds[order(preds$row_ids), ][[ifelse(outcome_type == "continuous", "response", "prob.1")]]
              })
  x <- matrix(Reduce(`c`, x), ncol = length(learners))
  ids <- unlist(lapply(learners, function(x) x$learner$id))
  cvRisk <- apply(x, 2, function(X) mean((X - y)^2))
  names(cvRisk) <- ids
  colnames(x) <- ids
  task <- make_mlr3_task(data.frame(x, y), "y", "continuous")
  if (ncol(x) == 1) {
    args <- list("mean")
  } else {
    args <- list("glmnet", lambda = 0, lower.limits = 0, intercept = FALSE)
  }
  metalearner <- make_base_learners(list(args), "continuous")[[1]]
  metalearner$train(task)
  list(risk = cvRisk, metalearner = metalearner)
}
