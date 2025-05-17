library(lme4, quietly = TRUE)
library(glmmTMB)
library(microbenchmark)
dat <- InstEval
dat$service <- as.numeric(dat$service) - 1  # convert to a 0/1 numeric vector
ctrl <- lmerControl(calc.derivs = FALSE)
form <- y ~ 1 + service + (1 | s) + (1 | d) + (1 | dept) + (0 + service | dept)
mlmer <- lmer(form, dat, REML = FALSE, control = ctrl)
print(summary(mlmer, correlation = FALSE))
tmbmod <- glmmTMB(form, dat)
print(summary(tmbmod))
microbenchmark(
  lmer = lmer(form, dat, REML = FALSE, control = ctrl),
  glmmTMB = glmmTMB(form, dat), times = 6
) |> print()
# R and package versions
print(R.version.string)
print(packageVersion("lme4"))
print(packageVersion("glmmTMB"))