lookup <- function(learners, outcome_type) {
  avail <- available_learners(outcome_type)
  avail[avail$learner %in% learners, ][["mlr3_learner"]]
}

#' Learners Available for Use
#'
#' @param outcome_type The outcome variable type.
#'
#' @return A \code{data.table} of available learners.
#' @export
#'
#' @examples
#' available_learners("binomial")
available_learners <- function(outcome_type = c("binomial", "continuous")) {
  if (match.arg(outcome_type) == "binomial") return(available_learners_classif())
  available_learners_regr()
}

available_learners_classif <- function() {
  data.table::data.table(
    learner = c("mean", "glm", "glmnet", "knn", "nnet", "lda", "naivebayes", "qda", "ranger", "svm", "xgboost", "earth", "lightgbm", "randomforest", "bart", "c50", "gam", "gaussianprocess", "glmboost"),
    mlr3_learner = paste0("classif.", c("featureless", "log_reg", "cv_glmnet", "kknn", "nnet", "lda", "naive_bayes", "qda", "ranger", "svm", "xgboost", "earth", "lightgbm", "randomForest", "bart", "C50", "gam", "gausspr", "glmboost")),
    mlr3_package = c("mlr3", rep("mlr3learners", 10), rep("mlr3extralearners", 8)),
    learner_package = c("stats", "stats", "glmnet", "kknn", "nnet", "MASS", "e1071", "MASS", "ranger", "e1071", "xgboost", "earth", "lightgbm", "randomForest", "dbarts", "C50", "mgcv", "kernlab", "mboost")
  )
}

available_learners_regr <- function() {
  data.table::data.table(
    learner = c("mean", "glm", "glmnet", "knn", "nnet", "ranger", "svm", "xgboost", "earth", "lightgbm", "randomforest", "bart", "gam", "gaussianprocess", "glmboost"),
    mlr3_learner = paste0("regr.", c("featureless", "lm", "cv_glmnet", "kknn", "nnet", "ranger", "svm", "xgboost", "earth", "lightgbm", "randomForest", "bart", "gam", "gausspr", "glmboost")),
    mlr3_package = c("mlr3", rep("mlr3learners", 7), rep("mlr3extralearners", 7)),
    learner_package = c("stats", "stats", "glmnet", "kknn", "nnet", "ranger", "e1071", "xgboost", "earth", "lightgbm", "randomForest", "dbarts", "mgcv", "kernlab", "mboost")
  )
}
