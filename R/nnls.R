# Modified from https://github.com/ecpolley/SuperLearner/blob/master/R/method.R method.NNLS()
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

# Modified from https://github.com/ecpolley/SuperLearner/blob/master/R/method.R method.CC_LS()
meta_CC_LS <- function(preds, Y, learners, obsWeights, ...) {
  cvRisk <- apply(preds, 2, function(x) mean(obsWeights * (x - Y)^2))
  names(cvRisk) <- learners

  compute <- function(x, y, wt = rep(1, length(y))) {
    wX <- sqrt(wt) * x
    wY <- sqrt(wt) * y
    D <- crossprod(wX)
    d <- crossprod(wX, wY)
    A <- cbind(rep(1, ncol(wX)), diag(ncol(wX)))
    bvec <- c(1, rep(0, ncol(wX)))
    fit <- quadprog::solve.QP(Dmat = D, dvec = d, Amat = A, bvec = bvec, meq = 1)
    invisible(fit)
  }

  modZ <- preds
  naCols <- which(apply(preds, 2, function(z) all(z == 0)))
  anyNACols <- length(naCols) > 0

  tol <- 8
  dupCols <- which(duplicated(round(preds, tol), MARGIN = 2))
  anyDupCols <- length(dupCols) > 0

  fit <- compute(x = modZ, y = Y, wt = obsWeights)
  coef <- fit$solution

  if (anyDupCols | anyNACols) {
    ind <- c(seq_along(coef), rmCols - 0.5)
    coef <- c(coef, rep(0, length(rmCols)))
    coef <- coef[order(ind)]
  }

  coef[coef < 1.0e-4] <- 0
  coef <- coef / sum(coef)

  list(cvRisk = cvRisk, coef = coef, optimizer = fit)
}

predict_CC_LS <- function(preds, coef, ...) {
  preds %*% matrix(coef)
}
