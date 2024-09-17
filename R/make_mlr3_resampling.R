make_mlr3_resampling <- function(task, folds) {
  if (inherits(task, "TaskRegr")) {
    out <- mlr3::rsmp("cv", folds = folds)
    return(out)
  }

  if (length(task$col_roles$group) != 0) {
    out <- mlr3::rsmp("cv", folds = folds)
    return(out)
  }

  task$col_roles$stratum <- task$col_roles$target
  mlr3::rsmp("cv", folds = folds)
}
