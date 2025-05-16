library(lme4, quietly = TRUE)
library(glmmTMB)
library(microbenchmark)
dat <- InstEval
dat$service <- as.numeric(dat$service) - 1  # convert to a 0/1 numeric vector
ctrl <- lmerControl(calc.derivs = FALSE)
form <- y ~ 1 + service + (1 | s) + (1 | d) + (1 | dept) + (0 + service | dept)
mlmer <- lmer(form, dat, REML = FALSE, control = ctrl)
summary(mlmer, correlation = FALSE)
tmbmod <- glmmTMB(form, dat)
summary(tmbmod)
microbenchmark(
  lmer = lmer(form, dat, REML = FALSE, control = ctrl),
  glmmTMB = glmmTMB(form, dat), times = 6
)
# R and package versions
R.version.string
packageVersion("lme4")
packageVersion("glmmTMB")