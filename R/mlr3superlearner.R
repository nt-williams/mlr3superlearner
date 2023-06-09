#' Super Learner Algorithm
#'
#' Implementation of the Super Learner algorithm using the `mlr3` framework.
#'
#' @param data [\code{data.frame}]\cr
#'  A \code{data.frame} containing predictors and target variable.
#' @param target [\code{character(1)}]\cr
#'  The name of the target variable in \code{data}.
#' @param library [\code{character}]\cr
#'  A vector of algorithms to be used for prediction.
#' @param metalearner [\code{character(1)}]\cr
#' @param outcome_type [\code{character(1)}]\cr
#'  The outcome variable type.
#' @param folds [\code{numeric(1)}]\cr
#'  The number of cross-validation folds.
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
#' @export
#'
#' @examples
#' library(mlr3superlearner)
#' n <- 1e3
#' W <- matrix(rnorm(n*3), ncol = 3)
#' A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
#' Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
#' tmp <- data.frame(W, A, Y)
#' fit <- mlr3superlearner(tmp, "Y", c("glm", "glmnet"), "glm", "binomial")
#' predict(fit, tmp)
mlr3superlearner <- function(data, target, library, metalearner,
                             outcome_type = c("binomial", "continuous"),
                             folds = 10L, newdata = NULL, group = NULL, info = FALSE) {
  checkmate::assert_character(target, len = 1)
  #checkmate::assert_character(library)
  checkmate::assert_character(metalearner, len = 1)
  checkmate::assert_number(folds)
  checkmate::assert_list(newdata, types = "list", null.ok = TRUE)

  ensemble <- make_base_learners(library, outcome_type)

  if (info) {
    lgr::get_logger("mlr3")$set_threshold("info")
    on.exit(lgr::get_logger("mlr3")$set_threshold("warn"))
  }

  resampling <- mlr3::rsmp("cv", folds = folds)
  task <- make_mlr3_task(data, target, outcome_type)

  if (!is.null(group)) {
    task$set_col_roles(group, "group")
  }

  meta <- compute_super_learner_weights(
    lapply(ensemble, function(algo) mlr3::resample(task, algo, resampling)),
    y = data[[target]],
    metalearner,
    outcome_type
  )

  ensemble <- lapply(ensemble, function(algo) algo$train(task))
  sl <- list(learners = ensemble,
             metalearner = meta$metalearner,
             risk = meta$risk,
             outcome_type = outcome_type,
             folds = folds,
             x = setdiff(names(data), target))

  class(sl) <- "mlr3superlearner"

  if (is.null(newdata)) {
    sl$preds <- NULL
    return(sl)
  }

  sl$preds <- lapply(newdata, function(x) predict.mlr3superlearner(sl, x))
  sl
}

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

compute_super_learner_weights <- function(learners, y, metalearner, outcome_type) {
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
  tmp <- data.frame(x, y)
  task <- make_mlr3_task(tmp, "y", outcome_type)
  has_necessary_packages(metalearner, outcome_type)
  args <- list(.key = lookup(metalearner, outcome_type))
  if (outcome_type == "binomial") args$predict_type <- "prob"
  metalearner <- do.call(mlr3::lrn, args)
  metalearner$train(task)
  list(risk = cvRisk, metalearner = metalearner)
}
