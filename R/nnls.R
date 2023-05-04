# Modified from https://github.com/ecpolley/SuperLearner/blob/master/R/method.R
meta_nnls <- function(preds, Y, learners, obsWeights, ...) {
  cvRisk <- apply(preds, 2, function(x) mean(obsWeights * (x - Y)^2))
  names(cvRisk) <- learners
  fit.nnls <- nnls::nnls(sqrt(obsWeights) * preds, sqrt(obsWeights) * Y)
  initCoef <- coef(fit.nnls)
  initCoef[is.na(initCoef)] <- 0
  if (all(initCoef == 0)) stop("All algorithms have zero weight", call. = FALSE)
  coef <- initCoef / sum(initCoef)
  list(cvRisk = cvRisk, coef = coef, optimizer = fit.nnls)
}

# Modified from https://github.com/ecpolley/SuperLearner/blob/master/R/method.R
predict_nnls <- function(preds, coef, ...) {
  if (all(coef == 0)) stop("All algorithms have zero weight", call. = FALSE)
  crossprod(t(preds[, coef != 0, drop = FALSE]), coef[coef != 0])[, 1]
}
