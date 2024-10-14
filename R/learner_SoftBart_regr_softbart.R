#' @title Regression Soft Bart Learner
#' @author nt-williams
#' @name mlr_learners_regr.softbart
#'
#' @description
#' FIXME: BRIEF DESCRIPTION OF THE LEARNER.
#' Calls [SoftBart::softbart_regression()] from CRAN: \CRANpkg{SoftBart} | 'SoftBart'.
#'
#' @section Initial parameter values:
#' FIXME: DEVIATIONS FROM UPSTREAM PARAMETERS. DELETE IF NOT APPLICABLE.
#'
#' @templateVar id regr.softbart
#' @template learner
#'
#' @references
#' `r format_bib(FIXME: ONE OR MORE REFERENCES FROM bibentries.R)`
#'
#' @template seealso_learner
#' @template example
#' @export
LearnerRegrSoftBart = R6::R6Class("LearnerRegrSoftBart",
  inherit = mlr3::LearnerRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = paradox::ps(
        num_tree = paradox::p_int(lower = 1, default = 20, tags = "train"),
        k = paradox::p_int(lower = 1, default = 2, tags = "train"),
        verbose = paradox::p_lgl(default = FALSE, tags = "train")
      )

      param_set$values = param_set$default

      super$initialize(
        id = "regr.softbart",
        packages = "SoftBart",
        feature_types = c("logical", "integer", "numeric", "factor", "ordered"),
        predict_types = c("response"),
        param_set = param_set,
        properties = c(),
        man = "mlr3superlearner::mlr_learners_regr.softbart",
        label = "Soft BART"
      )
    }
  ),
  private = list(
    .train = function(task) {
      pars = self$param_set$get_values(tags = "train")

      formula = task$formula()
      data = task$data()

      mlr3misc::invoke(
        SoftBart::softbart_regression,
        formula = formula,
        data = data,
        test_data = data,
        .args = pars
      )
    },
    .predict = function(task) {
      # get newdata and ensure same ordering in train and predict
      newdata = ordered_features(task, self)

      # Calculate predictions for the selected predict type.
      type = self$predict_type

      model = self$model
      model$dv$vars = setdiff(model$dv$vars, task$target_names)

      pred = mlr3misc::invoke(predict, model, newdata = newdata)

      list(response = unname(pred$mu_mean))
    }
  )
)

ordered_features <- function(task, learner) {
  cols = checkmate::`%??%`(names(learner$state$data_prototype), learner$state$feature_names)
  task$data(cols = intersect(cols, task$feature_names))
}
