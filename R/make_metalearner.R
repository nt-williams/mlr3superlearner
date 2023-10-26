make_metalearner <- function(outcome_type) {
  learner <- switch(outcome_type,
                    continuous = mlr3pipelines::LearnerRegrAvg$new(),
                    binomial = mlr3pipelines::LearnerClassifAvg$new(),
                    multiclass = mlr3pipelines::LearnerClassifAvg$new())

  if (outcome_type == "continuous") {
    return(learner)
  }

  learner$predict_type <- "prob"
  learner$param_set$values$measure <- "classif.logloss"
  learner
}
