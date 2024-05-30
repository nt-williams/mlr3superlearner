library <- c("glm", "gam", "ranger")

filt_cor <- po("filter", filter = flt("correlation"), filter.cutoff = 0.5)
filt_mim <- po("filter", filter = flt("mim"), filter.cutoff = 0.5)

per_rpart <- flt("performance", learner = mlr3::lrn("regr.rpart"))
per_glm_mse <- flt("performance",
                   learner = mlr3::lrn("regr.lm"),
                   measure = msr("regr.mse"))

filt_perf1 <- po("filter", filter = per_rpart, filter.nfeat = 3)
filt_perf2 <- po("filter", filter = per_glm_mse, filter.nfeat = 3)

filt_import <- po("filter",
                  filter = flt("importance", learner = lrn("regr.xgboost")),
                  filter.nfeat = 3)

filt_sf <- po("filter",
              filter = flt("selected_features", learner = lrn("regr.cv_glmnet")),
              filter.cutoff = 1)

mtcars_mlr3sl <- purrr::partial(mlr3superlearner,
                                data = mtcars,
                                target = "mpg",
                                library = library,
                                outcome_type = "continuous")

mtcars_mlr3sl()
mtcars_mlr3sl(filters = filt_cor)
mtcars_mlr3sl(filters = filt_mim)
mtcars_mlr3sl(filters = filt_perf1)
mtcars_mlr3sl(filters = filt_perf2)
mtcars_mlr3sl(filters = filt_import)
mtcars_mlr3sl(filters = filt_sf)
