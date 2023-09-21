make_base_learners <- function(library, outcome_type) {
  if (is.list(library)) {
    has_necessary_packages(purrr::map_chr(library, 1), outcome_type)

    stack <- lapply(library, function(info) {
      args <- as.list(info)[-1]
      args$.key <- lookup(info[[1]], outcome_type)
      args$id <- make_learner_id(info, outcome_type)
      if (outcome_type == "binomial") args$predict_type <- "prob"

      do.call(mlr3::lrn, args)
    })
  } else {
    has_necessary_packages(library, outcome_type)

    args <- list(.keys = lookup(library, outcome_type))
    if (outcome_type == "binomial") args$predict_type <- "prob"
    stack <- do.call(mlr3::lrns, args)
  }

  stack
}
