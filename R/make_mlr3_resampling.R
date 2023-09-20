make_mlr3_resampling <- function(task, folds) {
  if (inherits(task, "TaskRegr")) {
    out <- mlr3::rsmp("cv", folds = folds)
    return(out)
  }

  if (is.null(task$groups)) clusters <- NULL
  else clusters <- task$data(cols = task$groups)[, 1]

  ofolds <- origami::make_folds(task$nrow,
                                cluster_ids = clusters,
                                strata_ids = task$data(cols = task$target_names)[, 1])
  out <- rsmp("custom")
  out$instantiate(task,
                  lapply(ofolds, function(x) x$training_set),
                  lapply(ofolds, function(x) x$validation_set))
  out
}
