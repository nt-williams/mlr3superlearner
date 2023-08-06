#' @exportS3Method
print.mlr3superlearner <- function(object, ...) {
  weights <- coef(object$metalearner$model)
  weights <- weights[rownames(weights) %in% purrr::map_chr(object$learners, "id"), 1]
  weights <- weights / sum(weights)
  print(cbind(Risk = object$risk[order(names(object$risk))],
              Coefficients = weights[order(names(weights))]))
}
