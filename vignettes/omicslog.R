## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = TRUE,
  warning = TRUE
)


## ----setup, message=FALSE-----------------------------------------------------
library(omicslog)
library(SummarizedExperiment)
library(tidySummarizedExperiment)


## ----message=TRUE, warning=TRUE-----------------------------------------------
# Complete workflow in a single pipeline
result <- tidySummarizedExperiment::pasilla |>
  log_start() |>
  filter(condition == "treated") |>
  mutate(log_counts = log2(counts + 1)) |>
  filter(.feature == "FBgn0000003")

# View the object with its complete log history
result


## -----------------------------------------------------------------------------
sessionInfo()

