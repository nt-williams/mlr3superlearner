make_base_learners <- function(library, filters, outcome_type) {
  if (is.list(library)) {
    has_necessary_packages(purrr::map_chr(library, 1), outcome_type)

    stack <- lapply(library, function(info) {
      args <- as.list(info)[-1]
      args$.key <- lookup(info[[1]], outcome_type)
      args$id <- make_learner_id(info, outcome_type)
      if (outcome_type %in% c("binomial", "multiclass")) args$predict_type <- "prob"

      do.call(mlr3::lrn, args)
    })
  } else {
    has_necessary_packages(library, outcome_type)

    args <- list(.keys = lookup(library, outcome_type))
    if (outcome_type %in% c("binomial", "multiclass")) args$predict_type <- "prob"
    stack <- do.call(mlr3::lrns, args)
  }

  if (is.null(filters)) {
    return(stack)
  }

  make_filtered_base_learners(stack, filters)
}

make_filtered_base_learners <- function(stack, filters) {
  if (inherits(filters, c("PipeOp", "Graph"))) {
    return(lapply(stack, function(x) add_filter_to_learner(x, filters)))
  }

  if (is.list(filters)) {
    return(mapply(add_filter_to_learner, learner = stack,
                  filter = filters, SIMPLIFY = FALSE))
  }
}

#' @importFrom mlr3 as_learner
add_filter_to_learner <- function(learner, filter) {
  if (is.null(filter)) {
    return(learner)
  }
  as_learner(mlr3pipelines::concat_graphs(filter, learner, in_place = FALSE))
}
