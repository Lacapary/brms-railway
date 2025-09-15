# Load library
library(brms)

# Set seed for reproducibility
set.seed(123)

# Create dummy data
N <- 100
df <- data.frame(
  x1 = rnorm(N, mean = 0, sd = 1),
  x2 = rbinom(N, size = 1, prob = 0.5),  # binary predictor
  group = factor(rep(1:5, each = 20))    # grouping variable
)

# Response variable with some true underlying relationship
df$y <- 2 + 1.5*df$x1 - 0.8*df$x2 + rnorm(N, 0, 1)

# Fit a brms linear model (with group-level intercepts as an example)
fit <- brm(
  y ~ x1 + x2 + (1 | group),
  data = df,
  family = gaussian(),
  chains = 2, cores = 2, iter = 1000
)

summary(fit)
