has_necessary_packages <- function(learners, outcome_type) {
  avail <- available_learners(outcome_type)
  avail <- avail[avail$learner %in% learners, ]

  if ("mlr3extralearners" %in% avail$mlr3_package) {
    if ("mlr3extralearners" %in% .packages(all.available = TRUE)) {
      require("mlr3extralearners")
    } else {
      stop("'mlr3extralearners' required. Install 'mlr3extralearners'!", call. = F)
    }
  }

  unavailable <- avail$learner_package[!(avail$learner_package %in% .packages(T))]
  if (length(unavailable) != 0) {
    stop(paste0("Install ", paste0(unavailable, collapse = ", "), " with 'install.packages()'"), call. = F)
  }
}
