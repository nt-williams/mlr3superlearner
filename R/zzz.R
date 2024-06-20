.onLoad <- function(libname, pkgname) {
  lgr::get_logger("mlr3")$set_threshold("warn")

  mlr3::mlr_learners$add("classif.softbart", LearnerClassifSoftBart)
  mlr3::mlr_learners$add("regr.softbart", LearnerRegrSoftBart)
}
