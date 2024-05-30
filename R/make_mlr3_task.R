#' @importFrom mlr3 as_task_classif
#' @importFrom mlr3 as_task_regr
make_mlr3_task <- function(data, target, outcome_type) {
  args <- list(x = data,
               target = target,
               id = "mlr3superlearner_training_task")

  switch(outcome_type,
         binomial = do.call(as_task_classif, args),
         multiclass = do.call(as_task_classif, args),
         continuous = do.call(as_task_regr, args))
}
