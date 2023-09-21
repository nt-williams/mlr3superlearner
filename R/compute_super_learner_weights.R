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
