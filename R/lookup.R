lookup_algos <- function(algos, outcome_type) {
  .f <- ifelse(outcome_type == "classif", function(x) algos_classif[[x]], function(x) algos_regr[[x]])
  sapply(algos, .f, USE.NAMES = F)
}

algos_classif <- list(glmnet = "cv_glmnet",
                      knn = "kknn",
                      lda = "lda",
                      glm = "log_reg",
                      naive_bayes = "naive_bayes",
                      qda = "qda",
                      ranger = "ranger",
                      svm = "svm",
                      xgboost = "xgboost",
                      earth = "earth",
                      lightgbm = "lightgbm",
                      randomforest = "randomForest")

algos_regr <- list(glmnet = "cv_glmnet",
                   knn = "kknn",
                   lda = "lda",
                   glm = "lm",
                   naive_bayes = "naive_bayes",
                   nnet = "nnet",
                   ranger = "ranger",
                   svm = "svm",
                   xgboost = "xgboost",
                   bart = "bart",
                   earth = "earth",
                   lightgbm = "lightgbm",
                   randomforest = "randomForest")
