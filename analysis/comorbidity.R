#setwd("C:/Users/phsrtcow/Documents/GitHub/os-sch-children-2021")

# 1-year lookback period

# load dataset
df <- read.csv("output/input_comorbidity.csv")
df <- df[, -which(colnames(df) == "patient_id")]

# set up blank matrix for results
results <- matrix(nrow = 12, ncol = 7)

# add conditions as row names
conditions <- colnames(df)[1 : nrow(results)]
conditions <- gsub("_gp", "", conditions)
conditions <- gsub("_", " ", conditions)
conditions <- gsub("mi", "Myocardial infarction", conditions)
conditions <- gsub("hf", "Heart failure ", conditions)
rownames(results) <- stringr::str_to_sentence(conditions)

# set column names
colnames(results) <- c("Number of patients with record in TPP or SUS",
                       "Number of patients with record in TPP only",
                       "% of patients with record in TPP only",
                       "Number of patients with record in TPP and SUS",
                       "% of patients with record in TPP and SUS",
                       "Number of patients with record in SUS only",
                       "% of patients with record in SUS only")

# add values to results table
for (i in 1 : nrow(results)) {
  results[i, 1] <- sum(df[, i] == 1 | df[, i + nrow(results)] == 1)
  results[i, 2] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 0)
  results[i, 3] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 0) / results[i, 1]
  results[i, 4] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 1)
  results[i, 5] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 1) / results[i, 1]
  results[i, 6] <- sum(df[, i] == 0 & df[, i + nrow(results)] == 1)
  results[i, 7] <- sum(df[, i] == 0 & df[, i + nrow(results)] == 1) / results[i, 1]
}

# format percentages
library(scales)
results[, c(3,5,7)] <- apply(results[, c(3,5,7)], 2, percent, accuracy = 0.1)

# save table
write.csv(results, file = "output/comorbidity_table.csv")
rm(list = ls())

# 5-year lookback period

# load dataset
df <- read.csv("output/input_comorbidity_5y.csv")
df <- df[, -which(colnames(df) == "patient_id")]

# set up blank matrix for results
results <- matrix(nrow = 12, ncol = 7)

# add conditions as row names
conditions <- colnames(df)[1 : nrow(results)]
conditions <- gsub("_gp", "", conditions)
conditions <- gsub("_", " ", conditions)
conditions <- gsub("mi", "Myocardial infarction", conditions)
conditions <- gsub("hf", "Heart failure ", conditions)
rownames(results) <- stringr::str_to_sentence(conditions)

# set column names
colnames(results) <- c("Number of patients with record in TPP or SUS",
                       "Number of patients with record in TPP only",
                       "% of patients with record in TPP only",
                       "Number of patients with record in TPP and SUS",
                       "% of patients with record in TPP and SUS",
                       "Number of patients with record in SUS only",
                       "% of patients with record in SUS only")

# add values to results table
for (i in 1 : nrow(results)) {
  results[i, 1] <- sum(df[, i] == 1 | df[, i + nrow(results)] == 1)
  results[i, 2] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 0)
  results[i, 3] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 0) / results[i, 1]
  results[i, 4] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 1)
  results[i, 5] <- sum(df[, i] == 1 & df[, i + nrow(results)] == 1) / results[i, 1]
  results[i, 6] <- sum(df[, i] == 0 & df[, i + nrow(results)] == 1)
  results[i, 7] <- sum(df[, i] == 0 & df[, i + nrow(results)] == 1) / results[i, 1]
}

# format percentages
library(scales)
results[, c(3,5,7)] <- apply(results[, c(3,5,7)], 2, percent, accuracy = 0.1)

# save table
write.csv(results, file = "output/comorbidity_table_5y.csv")
