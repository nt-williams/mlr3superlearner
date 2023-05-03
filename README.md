
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mlr3superlearner

<!-- badges: start -->
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
fit <- mlr3superlearner(tmp, "Y", c("glm", "glmnet"), "binomial")
#> INFO  [12:37:00.975] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 1/10)
#> INFO  [12:37:01.006] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 2/10)
#> INFO  [12:37:01.031] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 3/10)
#> INFO  [12:37:01.039] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 4/10)
#> INFO  [12:37:01.083] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 5/10)
#> INFO  [12:37:01.091] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 6/10)
#> INFO  [12:37:01.099] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 7/10)
#> INFO  [12:37:01.107] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 8/10)
#> INFO  [12:37:01.115] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 9/10)
#> INFO  [12:37:01.123] [mlr3] Applying learner 'classif.log_reg' on task 'mlr3superlearner_training_task' (iter 10/10)
#> INFO  [12:37:01.155] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 1/10)
#> INFO  [12:37:01.669] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 2/10)
#> INFO  [12:37:01.708] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 3/10)
#> INFO  [12:37:01.753] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 4/10)
#> INFO  [12:37:01.792] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 5/10)
#> INFO  [12:37:01.835] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 6/10)
#> INFO  [12:37:01.873] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 7/10)
#> INFO  [12:37:01.916] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 8/10)
#> INFO  [12:37:01.954] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 9/10)
#> INFO  [12:37:01.999] [mlr3] Applying learner 'classif.cv_glmnet' on task 'mlr3superlearner_training_task' (iter 10/10)
fit
#>                        Risk      Coef
#> classif.log_reg   0.2177859 0.7850047
#> classif.cv_glmnet 0.2215212 0.2149953
head(predict(fit, tmp))
#> [1] 0.6357850 0.7894241 0.5370076 0.6477620 0.6133470 0.5638412
```
