
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mlr3superlearner

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of mlr3superlearner from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("nt-williams/mlr3superlearner")
```

## Example

``` r
library(mlr3superlearner)
#> Loading required package: mlr3learners
#> Loading required package: mlr3

n <- 1e3
W <- matrix(rnorm(n*3), ncol = 3)
A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
Y <- rbinom(n, 1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2))
tmp <- data.frame(W, A, Y)
fit <- mlr3superlearner(tmp, Y ~ -1 + ., c("glm", "glmnet"), "binomial")
fit
#>                        Risk      Coef
#> classif.log_reg   0.2121975 0.8595963
#> classif.cv_glmnet 0.2167867 0.1404037
head(predict(fit, tmp))
#>           [,1]
#> [1,] 0.8205302
#> [2,] 0.7543708
#> [3,] 0.5480276
#> [4,] 0.7550671
#> [5,] 0.5574172
#> [6,] 0.7740882
```

## Available learners

``` r
knitr::kable(available_learners("binomial"))
```

| learner         | mlr3_learner         | mlr3_package      | learner_package |
|:----------------|:---------------------|:------------------|:----------------|
| glm             | classif.log_reg      | mlr3learners      | stats           |
| glmnet          | classif.cv_glmnet    | mlr3learners      | glmnet          |
| knn             | classif.kknn         | mlr3learners      | kknn            |
| nnet            | classif.nnet         | mlr3learners      | nnet            |
| lda             | classif.lda          | mlr3learners      | MASS            |
| naivebayes      | classif.naive_bayes  | mlr3learners      | e1071           |
| qda             | classif.qda          | mlr3learners      | MASS            |
| ranger          | classif.ranger       | mlr3learners      | ranger          |
| svm             | classif.svm          | mlr3learners      | e1071           |
| xgboost         | classif.xgboost      | mlr3learners      | xgboost         |
| earth           | classif.earth        | mlr3extralearners | earth           |
| lightgbm        | classif.lightgbm     | mlr3extralearners | lightgbm        |
| randomforest    | classif.randomForest | mlr3extralearners | randomForest    |
| bart            | classif.bart         | mlr3extralearners | dbarts          |
| c50             | classif.C50          | mlr3extralearners | C50             |
| gam             | classif.gam          | mlr3extralearners | mgcv            |
| gaussianprocess | classif.gausspr      | mlr3extralearners | kernlab         |
| glmboost        | classif.glmboost     | mlr3extralearners | mboost          |

``` r
knitr::kable(available_learners("continuous"))
```

| learner         | mlr3_learner      | mlr3_package      | learner_package |
|:----------------|:------------------|:------------------|:----------------|
| glm             | regr.lm           | mlr3learners      | stats           |
| glmnet          | regr.cv_glmnet    | mlr3learners      | glmnet          |
| knn             | regr.kknn         | mlr3learners      | kknn            |
| nnet            | regr.nnet         | mlr3learners      | nnet            |
| ranger          | regr.ranger       | mlr3learners      | ranger          |
| svm             | regr.svm          | mlr3learners      | e1071           |
| xgboost         | regr.xgboost      | mlr3learners      | xgboost         |
| earth           | regr.earth        | mlr3extralearners | earth           |
| lightgbm        | regr.lightgbm     | mlr3extralearners | lightgbm        |
| randomforest    | regr.randomForest | mlr3extralearners | randomForest    |
| bart            | regr.bart         | mlr3extralearners | dbarts          |
| gam             | regr.gam          | mlr3extralearners | mgcv            |
| gaussianprocess | regr.gausspr      | mlr3extralearners | kernlab         |
| glmboost        | regr.glmboost     | mlr3extralearners | mboost          |
