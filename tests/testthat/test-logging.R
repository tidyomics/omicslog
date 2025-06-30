test_that("log, filter, and mutate operations work correctly on pasilla dataset", {
  skip_if_not_installed("tidySummarizedExperiment")
  
  library(tidySummarizedExperiment)
  
  # Load the pasilla dataset and apply transformations
  result <- tidySummarizedExperiment::pasilla |>
    log_start() |>
    extract(col = type,into = c("fragment","end"),regex = "([[:alnum:]]+)_([[:alnum:]]+)") |>
    select(!end) |>
    filter(condition == "treated") |>
    mutate(log_counts = log2(counts + 1)) |>
    filter(.feature == "FBgn0000003") |>
    slice(3)
  
  # Test
  expect_s4_class(result, "SummarizedExperimentLogged")
  expect_identical(dim(result), c(1L, ncol(result)))  # Only one gene should remain
  expect_true("log_counts" %in% names(assays(result)))
  expect_true(result$fragment == "paired")
  expect_true(length(result@log_history) == 6)  # Should have 3 log entries: 2 filters and 1 mutate
  expect_match(result@log_history[1], "extract: extracted '\\w+' into")
  expect_match(result@log_history[2], "select: removed \\d+")
  expect_match(result@log_history[3], "filter: removed \\d+ samples")
  expect_match(result@log_history[4], "mutate: added \\d+ new column\\(s\\): log_counts")
  expect_match(result@log_history[5], "filter: removed \\d+ genes")
  expect_match(result@log_history[6], "slice: Kept \\d+/\\d+ rows")
})

test_that("base R subsetting operations are logged correctly", {
  skip_if_not_installed("tidySummarizedExperiment")
  
  library(tidySummarizedExperiment)
  
  # Create a logged object
  se_logged <- tidySummarizedExperiment::pasilla |>
    log_start()
  
  # Test row subsetting
  result_rows <- se_logged[1:10, ]
  expect_s4_class(result_rows, "SummarizedExperimentLogged")
  expect_identical(dim(result_rows), c(10L, ncol(se_logged)))
  expect_true(length(result_rows@log_history) == 1)
  expect_match(result_rows@log_history[1], "subset: removed \\d+ genes")
  
  # Test column subsetting
  result_cols <- se_logged[, colData(se_logged)$condition == "treated"]
  expect_s4_class(result_cols, "SummarizedExperimentLogged")
  expect_identical(nrow(result_cols), nrow(se_logged))
  expect_true(length(result_cols@log_history) == 1)
  expect_match(result_cols@log_history[1], "subset: removed \\d+ samples")
  
  # Test both row and column subsetting
  result_both <- se_logged[1:5, colData(se_logged)$condition == "treated"]
  expect_s4_class(result_both, "SummarizedExperimentLogged")
  expect_identical(dim(result_both), c(5L, sum(colData(se_logged)$condition == "treated")))
  expect_true(length(result_both@log_history) >= 2)
  expect_true(any(grepl("subset: removed.*genes", result_both@log_history)))
  expect_true(any(grepl("subset: removed.*samples", result_both@log_history)))
  
  # Test that no log is added when dimensions don't change
  result_no_change <- se_logged[1:nrow(se_logged), ]
  expect_s4_class(result_no_change, "SummarizedExperimentLogged")
  expect_identical(dim(result_no_change), dim(se_logged))
  expect_true(length(result_no_change@log_history) == 0)
}) 
