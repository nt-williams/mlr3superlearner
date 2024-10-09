has_necessary_packages <- function(learners, outcome_type) {
  avail <- available_learners(outcome_type)
  avail <- avail[avail$learner %in% learners, ]

  if ("mlr3extralearners" %in% avail$mlr3_package) {
    if (!("mlr3extralearners" %in% (.packages()))) {
      if ("mlr3extralearners" %in% .packages(all.available = TRUE)) {
        cli::cli_abort("{.pkg mlr3extralearners} required. Run {.code library(mlr3extralearners)}")
      } else {
        cli::cli_abort("{.pkg mlr3extralearners} required. Install with {.code remotes::install_github('mlr-org/mlr3extralearners@*release')}")
      }
    }
  }

  if ("mlr3torch" %in% avail$mlr3_package) {
    if (!("mlr3torch" %in% (.packages()))) {
      if ("mlr3torch" %in% .packages(all.available = TRUE)) {
        cli::cli_abort("{.pkg mlr3torch} required. Run {.code library(mlr3torch)}")
      } else {
        cli::cli_abort("{.pkg mlr3torch} required. Install with {.code install.packages('mlr3torch')}")
      }
    }
  }

  has_pkg <- sapply(avail$learner_package, function(x) (requireNamespace(x, quietly = TRUE)))
  unavailable <- avail$learner_package[!has_pkg]
  if (length(unavailable) != 0) {
    cli::cli_abort("Packages {.pkg {unavailable}} required. Install with {.code install.packages()}.")
  }
}
