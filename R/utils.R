make_learner_id <- function(x, outcome_type) {
  predicate <- ifelse(outcome_type == "continuous", "regr", "classif")
  if (length(x) > 1) {
    if (!is.null(x$id)) return(paste0(predicate, ".", x$id))
    args <- paste0(paste0(names(x[-1]), "_", x[-1]), collapse = "_and_")
    return(paste0(predicate, ".", x[[1]], "_and_", args))
  }
  paste0(predicate, ".", x[[1]])
}
