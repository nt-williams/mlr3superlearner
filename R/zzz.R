.onLoad <- function(libname, pkgname) {
  lgr::get_logger("mlr3")$set_threshold("warn")
}
