SLmlr3 <- function(data, target, library, outcome_type = c("binomial", "continuous"), folds = 10L) {
  resampling <- mlr3::rsmp("cv", folds = folds)
  task <- make_mlr3_task(data, target, outcome_type)
  ensemble <- make_base_learners(library, outcome_type)

  weights <- compute_super_learner_weights(
    lapply(ensemble, function(algo) mlr3::resample(task, algo, resampling)),
    y = data[[target]],
    outcome_type
  )

  ensemble <- lapply(ensemble, function(algo) algo$train(task))
  sl <- list(learners = ensemble, weights = weights, outcome_type = outcome_type, folds = folds)
  class(sl) <- "SLmlr3"
  sl
}

predict.SLmlr3 <- function(object, newdata) {
  .f <- ifelse(object$outcome_type == "continuous",
               function(x) x$predict_newdata(newdata)$response,
               function(x) x$predict_newdata(newdata)$prob[, 2])
  z <- lapply(object$learners, .f)
  z <- matrix(Reduce(`c`, z), ncol = length(object$learners))
  SuperLearner::method.NNLS()$computePred(z, object$weights$coef)[, 1]
}

make_mlr3_task <- function(data, target, outcome_type) {
  if (outcome_type == "binomial") {
    task <- mlr3::as_task_classif(data,
                                  target = target,
                                  id = "SLmlr3_training_task")
    return(task)
  }

  mlr3::as_task_regr(data,
                     target = target,
                     id = "SLmlr3_training_task")
}

make_base_learners <- function(library, outcome_type) {
  predicate <- ifelse(outcome_type == "binomial", "classif", "regr")
  if (predicate == "classif") {
    return(mlr3::lrns(glue::glue("classif.{lookup_algos(library, 'classif')}"), predict_type = "prob"))
  }
  mlr3::lrns(glue::glue("regr.{lookup_algos(library, 'regr')}"))
}

lookup_algos <- function(algos, outcome_type) {
  .f <- ifelse(outcome_type == "classif", function(x) algos_classif[[x]], function(x) algos_regr[[x]])
  sapply(algos, .f, USE.NAMES = F)
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

algos_classif <- list(glmnet = "cv_glmnet",
                      knn = "kknn",
                      lda = "lda",
                      glm = "log_reg",
                      naive_bayes = "naive_bayes",
                      nnet = "nnet",
                      qda = "qda",
                      ranger = "ranger",
                      svm = "svm",
                      xgboost = "xgboost")

algos_regr <- list(glmnet = "cv_glmnet",
                   knn = "kknn",
                   lda = "lda",
                   glm = "lm",
                   naive_bayes = "naive_bayes",
                   nnet = "nnet",
                   qda = "qda",
                   ranger = "ranger",
                   svm = "svm",
                   xgboost = "xgboost",
                   bart = "bart")
