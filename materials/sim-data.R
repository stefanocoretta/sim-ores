set.seed(123)

n <- 150

data <- data.frame(
  id = 1:n,
  age = sample(18:70, n, replace = TRUE),
  gender = sample(c("female", "male", "non_binary"), n, replace = TRUE, prob = c(0.48, 0.48, 0.04)),
  education = sample(c("secondary", "undergrad", "postgrad"), n, replace = TRUE, prob = c(0.4, 0.4, 0.2)),
  income = round(rnorm(n, mean = 2500, sd = 800)),
  hours_online = round(rnorm(n, mean = 3.5, sd = 1.5), 1),
  trust_science = sample(1:5, n, replace = TRUE),
  region = sample(c("urban", "suburban", "rural"), n, replace = TRUE)
)

# outcome depends weakly on predictors
data$policy_support <- pmin(pmax(
  round(0.5 * data$trust_science + 0.001 * data$income + rnorm(n, 0, 1)),
  1), 5)

## --- Introduce missingness ---

# MCAR: ~10% missing in selected variables
mcar_vars <- c("age", "hours_online", "trust_science")
for (v in mcar_vars) {
  idx <- sample(1:n, size = round(0.1 * n))
  data[idx, v] <- NA
}

# MAR: income more likely missing for lower education
prob_miss_income <- ifelse(data$education == "secondary", 0.2,
                           ifelse(data$education == "undergrad", 0.1, 0.05))
miss_income <- runif(n) < prob_miss_income
data$income[miss_income] <- NA

# Small amount of missing outcome (~5%)
idx_outcome <- sample(1:n, size = round(0.05 * n))
data$policy_support[idx_outcome] <- NA

write.csv(data, "rescomp-quant/survey-data.csv", row.names = FALSE)
write.csv(na.omit(data), "rescomp-quant/data-complete.csv", row.names = FALSE)

library(HH)

likert_vars <- c("trust_science", "policy_support")
for (v in likert_vars) {
  data[[v]] <- factor(data[[v]], levels = 1:5, ordered = TRUE)
}

plot_data <- na.omit(data[, c("trust_science", "policy_support", "region")])

png("rescomp-quant/likert-aggregated.png")
likert(~ trust_science + policy_support, data = plot_data)
dev.off()

png("rescomp-quant/likert-by-region.png", width = 800, height = 600)
likert(~ trust_science + policy_support | region, data = plot_data)
dev.off()
