library(testthat)
library(tidySummarizedExperiment)

test_that("Multiple filter operations are properly logged", {
  # Create a test SummarizedExperiment
  se <- tidySummarizedExperiment::pasilla
  
  # Convert to logged version
  se_logged <- log_start(se)
  
  # Apply first filter
  se_filtered1 <- se_logged |>
    filter(condition == "treated")
  
  # Apply second filter
  se_filtered2 <- se_filtered1 |>
    filter(type == "single_end")
  
  se_filtered3 <- se_filtered2 |>
    extract(col = type,into = c("fragment","end"),regex = "([[:alnum:]]+)_([[:alnum:]]+)")
  
  # There should be at least two log entries (could be more if both rows and columns filtered)
  expect_true(length(se_filtered2@log_history) >= 2)
  
  # Check that at least one log entry mentions samples
  expect_true(any(grepl("filter: removed.*samples", se_filtered2@log_history)))
  
  # Verifyng that 'extract' added extra columns
  expect_true(ncol(colData(se_filtered2)) < ncol(colData(se_filtered3)))
})

test_that("Base R filtering operations are properly logged", {
  # Create a test SummarizedExperiment
  se <- tidySummarizedExperiment::pasilla
  
  # Convert to logged version
  se_logged <- log_start(se)
  
  # Apply base R filtering
  result_filtered <- se_logged[1:5, colData(se_logged)$dex == "untrt"]
  
  # There should be at least two log entries (could be more if both rows and columns filtered)
  expect_true(length(result_filtered@log_history) >= 2)
  
  # Check that at least one log entry mentions genes
  expect_true(any(grepl("subset: removed.*genes", result_filtered@log_history)))
  
  # Check that at least one log entry mentions samples
  expect_true(any(grepl("subset: removed.*samples", result_filtered@log_history)))
}) 