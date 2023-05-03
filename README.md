
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
fit
#>                        Risk       Coef
#> classif.log_reg   0.2079324 0.93251894
#> classif.cv_glmnet 0.2136061 0.06748106
head(predict(fit, tmp))
#> [1] 0.7588227 0.7728591 0.5877769 0.7317636 0.7589385 0.7867102
```
