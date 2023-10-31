
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mlr3superlearner

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/nt-williams/mlr3superlearner/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nt-williams/mlr3superlearner/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

An modern implementation of the [Super
Learner](https://biostats.bepress.com/ucbbiostat/paper266/) prediction
algorithm using the [mlr3](https://mlr3.mlr-org.com/) framework, and an
adherence to the recommendations of [Phillips, van der Laan, Lee, and
Gruber (2023)](https://doi.org/10.1093/ije/dyad023)

## Installation

You can install the development version of mlr3superlearner from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("nt-williams/mlr3superlearner")
```

## Examples

``` r
library(mlr3superlearner)
#> Loading required package: mlr3learners
#> Loading required package: mlr3
library(mlr3extralearners)

# No hyperparameters
mlr3superlearner(mtcars, "mpg", c("mean", "glm", "svm", "ranger"), 
                 outcome_type = "continuous")
#> ℹ n effective = 32. Setting cross-validation folds as 20
#> ══ `mlr3superlearner()` ════════════════════════════════════════════════════════
#>                       Risk Coefficients
#> regr.featureless 37.104403            0
#> regr.lm          12.711196            0
#> regr.svm         11.467010            0
#> regr.ranger       5.578052            1

# With hyperparameters
fit <- mlr3superlearner(mtcars, "mpg", 
                        list("mean", "glm", "xgboost", "svm", "earth",
                             list("nnet", trace = FALSE),
                             list("ranger", num.trees = 500, id = "ranger1"),
                             list("ranger", num.trees = 1000, id = "ranger2")), 
                        outcome_type = "continuous")
#> ℹ n effective = 32. Setting cross-validation folds as 20

fit
#> ══ `mlr3superlearner()` ════════════════════════════════════════════════════════
#>                                 Risk Coefficients
#> regr.mean                  37.120583       0.0000
#> regr.glm                   12.568308       0.0000
#> regr.xgboost              225.527789       0.0000
#> regr.svm                   11.468963       0.0000
#> regr.earth                  6.833758       0.0287
#> regr.nnet_and_trace_FALSE  36.160005       0.0000
#> regr.ranger1                5.232577       0.9713
#> regr.ranger2                5.760638       0.0000

head(data.frame(pred = predict(fit, mtcars), truth = mtcars$mpg))
#>       pred truth
#> 1 20.65693  21.0
#> 2 20.59887  21.0
#> 3 24.18581  22.8
#> 4 20.09178  21.4
#> 5 17.60347  18.7
#> 6 18.83551  18.1
```

### Feature selection

``` r
library(mlr3pipelines)
library(mlr3filters)

filter <- po("filter",
             filter = flt("selected_features", learner = lrn("regr.cv_glmnet")),
             filter.cutoff = 1)

mlr3superlearner(mtcars, "mpg", 
                 list("mean", "glm", "xgboost", "svm", "earth",
                      list("nnet", trace = FALSE),
                      list("ranger", num.trees = 500, id = "ranger1"),
                      list("ranger", num.trees = 1000, id = "ranger2")), 
                 filter,
                 "continuous")
#> ℹ n effective = 32. Setting cross-validation folds as 20
#> ══ `mlr3superlearner()` ════════════════════════════════════════════════════════
#>                                                   Risk Coefficients
#> selected_features.regr.mean                  37.506877       0.0000
#> selected_features.regr.glm                    7.801916       0.0431
#> selected_features.regr.xgboost              225.949228       0.0003
#> selected_features.regr.svm                    7.435692       0.0000
#> selected_features.regr.earth                  6.424393       0.4210
#> selected_features.regr.nnet_and_trace_FALSE  37.338876       0.0000
#> selected_features.regr.ranger1                6.804650       0.0000
#> selected_features.regr.ranger2                6.063907       0.5356
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
| rpart           | classif.rpart        | mlr3              | rpart           |

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
| rpart           | regr.rpart        | mlr3              | rpart           |

``` r
knitr::kable(available_learners("multiclass"))
```

| learner      | mlr3_learner         | mlr3_package      | learner_package |
|:-------------|:---------------------|:------------------|:----------------|
| mean         | classif.featureless  | mlr3              | stats           |
| rpart        | classif.rpart        | mlr3              | rpart           |
| gausspr      | classif.gausspr      | mlr3extralearners | kernlab         |
| lightgbm     | classif.lightgbm     | mlr3extralearers  | lightgbm        |
| randomforest | classif.randomForest | mlr3extralearners | randomForest    |
| glmnet       | classif.glmnet       | mlr3learners      | glmnet          |
| cv_glmnet    | classif.cv_glmnet    | mlr3learners      | glmnet          |
| knn          | classif.kknn         | mlr3learners      | kknn            |
| lda          | classif.lda          | mlr3learners      | MASS            |
| multinom     | classif.multinom     | mlr3learners      | nnet            |
| naivebayes   | classif.naive_bayes  | mlr3learners      | e1071           |
| nnet         | classif.nnet         | mlr3learners      | nnet            |
| ranger       | classif.ranger       | mlr3learners      | ranger          |
| svm          | classif.svm          | mlr3learners      | e1071           |
| xgboost      | classif.xgboost      | mlr3learners      | xgboost         |
