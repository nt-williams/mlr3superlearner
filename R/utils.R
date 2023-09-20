make_learner_id <- function(x, outcome_type) {
  predicate <- ifelse(outcome_type == "continuous", "regr", "classif")
  if (length(x) > 1) {
    if (!is.null(x$id)) return(paste0(predicate, ".", x$id))
    args <- paste0(paste0(names(x[-1]), "_", x[-1]), collapse = "_and_")
    return(paste0(predicate, ".", x[[1]], "_and_", args))
  }
  paste0(predicate, ".", x[[1]])
}

set_folds <- function(n, outcome_type, target) {
  if (outcome_type == "binomial") {
    nrare <- n*min(mean(target), 1 - mean(target))
    neff <- min(n, 5*nrare)
  } else {
    neff <- n
  }

  if (neff < 30) return(neff)
  if (neff < 500) return(20)
  if (neff < 5000) return(10)
  if (neff < 1e4) return(5)
  2
}
