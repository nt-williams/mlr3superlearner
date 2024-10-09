make_base_learners <- function(library, outcome_type) {
  if (is.list(library)) {
    has_necessary_packages(purrr::map_chr(library, 1), outcome_type)

    stack <- lapply(library, function(info) {
      args <- as.list(info)[-1]
      args$.key <- lookup(info[[1]], outcome_type)

      if (outcome_type == "binomial") args$predict_type <- "prob"

      if (!any(names(args) == "filter")) {
        args$id <- make_learner_id(info, outcome_type)
        return(do.call(mlr3::lrn, args))
      }

      filter <- args[[which(names(args) == "filter")]]
      args <- args[!(names(args) == "filter")]
      args$id <- make_learner_id(info[!(names(info) == "filter")], outcome_type)
      learner <- do.call(mlr3::lrn, args)

      as_learner(mlr3pipelines::concat_graphs(filter, learner))
    })
  } else {
    has_necessary_packages(library, outcome_type)

    args <- list(.keys = lookup(library, outcome_type))
    if (outcome_type == "binomial") args$predict_type <- "prob"
    stack <- do.call(mlr3::lrns, args)
  }

  stack
}
