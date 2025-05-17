test_that("log, filter, and mutate operations work correctly on pasilla dataset", {
  skip_if_not_installed("tidySummarizedExperiment")
  
  library(tidySummarizedExperiment)
  
  # Load the pasilla dataset and apply transformations
  result <- tidySummarizedExperiment::pasilla |>
    log_start() |>
    filter(condition == "treated") |>
    mutate(log_counts = log2(counts + 1)) |>
    filter(.feature == "FBgn0000003")
  
  # Tests
  expect_s4_class(result, "SummarizedExperimentLogged")
  expect_identical(dim(result), c(1L, ncol(result)))  # Only one gene should remain
  expect_true("log_counts" %in% names(assays(result)))
  expect_true(length(result@log_history) == 3)  # Should have 3 log entries: 2 filters and 1 mutate
  expect_match(result@log_history[1], "filter: removed \\d+ samples")
  expect_match(result@log_history[2], "mutate: added 1 new column\\(s\\): log_counts")
  expect_match(result@log_history[3], "filter: removed \\d+ genes")
}) 
