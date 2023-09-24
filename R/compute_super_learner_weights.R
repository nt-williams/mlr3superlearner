compute_super_learner_weights <- function(learners, y, outcome_type, group) {
  x <- lapply(learners,
              function(x) {
                preds <- data.table::as.data.table(x$prediction())
                preds[order(preds$row_ids), ][[ifelse(outcome_type == "continuous", "response", "prob.1")]]
              })
  x <- matrix(Reduce(`c`, x), ncol = length(learners))
  ids <- unlist(lapply(learners, function(x) x$learner$id))
  cvRisk <- apply(x, 2, function(X) compute_loss(X, y, outcome_type, group))
  names(cvRisk) <- ids
  colnames(x) <- ids
  task <- make_mlr3_task(data.frame(x, y), "y", "continuous")
  if (ncol(x) == 1) {
    args <- list("mean")
  } else {
    args <- list("glmnet", lambda = 0, lower.limits = 0, intercept = FALSE)
  }
  metalearner <- make_base_learners(list(args), NULL, "continuous")[[1]]
  metalearner$train(task)
  list(risk = cvRisk, metalearner = metalearner)
}

compute_loss <- function(x, y, outcome_type, group) {
  x <- split(x, group)
  y <- split(y, group)

  switch(outcome_type,
         binomial = mean(mapply(loss_nll, x = x, y = y)),
         continuous = mean(mapply(loss_mse, x = x, y = y)))
}

loss_mse <- function(x, y) mean((x - y)^2)
loss_nll <- function(x, y) -mean(y*log(x) + (1 - y)*log(1 - x))
