
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mlr3superlearner

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/nt-williams/mlr3superlearner/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nt-williams/mlr3superlearner/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

An implementation of the [Super
Learner](https://biostats.bepress.com/ucbbiostat/paper266/) prediction
algorithm using the [mlr3](https://mlr3.mlr-org.com/) framework.

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

# No hyperparameters
fit <- mlr3superlearner(mtcars, "mpg", c("mean", "glm", "svm", "ranger"), "continuous")

# With hyperparameters
fit <- mlr3superlearner(mtcars, "mpg", 
                        list("mean", "glm", "xgboost", "svm", "earth",
                             list("nnet", trace = FALSE),
                             list("ranger", num.trees = 500, id = "ranger1"),
                             list("ranger", num.trees = 1000, id = "ranger2")), 
                        "continuous", 
                        folds = 20)
#> Loading required package: mlr3extralearners

fit
#>                                 Risk Coefficients
#> regr.earth                  8.173546            0
#> regr.glm                   11.828231            0
#> regr.mean                  37.507090            0
#> regr.nnet_and_trace_FALSE  38.384537            0
#> regr.ranger1                5.453984            1
#> regr.ranger2                5.859746            0
#> regr.svm                   10.620193            0
#> regr.xgboost              226.389150            0

head(data.frame(pred = predict(fit, mtcars), truth = mtcars$mpg))
#>       pred truth
#> 1 20.66675  21.0
#> 2 20.67258  21.0
#> 3 24.13711  22.8
#> 4 20.14333  21.4
#> 5 17.63573  18.7
#> 6 18.95581  18.1
```

## Available learners

``` r
knitr::kable(available_learners("binomial"))
```

| learner         | mlr3_learner         | mlr3_package      | learner_package |
|:----------------|:---------------------|:------------------|:----------------|
| mean            | classif.featureless  | mlr3              | stats           |
| glm             | classif.log_reg      | mlr3learners      | stats           |
| glmnet          | classif.glmnet       | mlr3learners      | glmnet          |
| cv_glmnet       | classif.cv_glmnet    | mlr3learners      | glmnet          |
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
| nloptr          | classif.avg          | mlr3pipelines     | nloptr          |

``` r
knitr::kable(available_learners("continuous"))
```

| learner         | mlr3_learner      | mlr3_package      | learner_package |
|:----------------|:------------------|:------------------|:----------------|
| mean            | regr.featureless  | mlr3              | stats           |
| glm             | regr.lm           | mlr3learners      | stats           |
| glmnet          | regr.glmnet       | mlr3learners      | glmnet          |
| cv_glmnet       | regr.cv_glmnet    | mlr3learners      | glmnet          |
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
