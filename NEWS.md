# mlr3superlearner 0.1.3

* Can now add a parameter `filter` to learners hyperparameters for feature selection.

# mlr3superlearner 0.1.2

* Removed warning about using blocked instead of stratified resampling (issue #14).
* The chosen number of folds is now only printed to the console if `info = TRUE` (issue #13).
* Speed increases if only a single learner by avoiding unnecessary cross-validation (issue #15).

# mlr3superlearner 0.1.1

* Initial CRAN submission.
