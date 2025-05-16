test_that("SummarizedExperimentLogged class is created correctly", {
  # Create a simple SummarizedExperiment object
  counts <- matrix(rpois(100, 10), nrow = 10, ncol = 10)
  rownames(counts) <- paste0("gene", 1:10)
  colnames(counts) <- paste0("sample", 1:10)
  
  colData <- data.frame(
    condition = rep(c("treated", "control"), each = 5),
    batch = sample(1:3, 10, replace = TRUE)
  )
  
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(counts = counts),
    colData = colData
  )
  
  # Log the object
  logged_se <- log(se)
  
  # Tests
  expect_s4_class(logged_se, "SummarizedExperimentLogged")
  expect_identical(dim(logged_se), dim(se))
  expect_true(length(logged_se@log_history) == 0)
})

test_that("filter tracks removal of columns (samples)", {
  # Create a simple SummarizedExperiment object
  counts <- matrix(rpois(100, 10), nrow = 10, ncol = 10)
  rownames(counts) <- paste0("gene", 1:10)
  colnames(counts) <- paste0("sample", 1:10)
  
  colData <- data.frame(
    condition = rep(c("treated", "control"), each = 5),
    batch = sample(1:3, 10, replace = TRUE)
  )
  
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(counts = counts),
    colData = colData
  )
  
  # Log the object and filter
  logged_se <- log(se)
  filtered <- filter(logged_se, condition == "treated")
  
  # Tests
  expect_s4_class(filtered, "SummarizedExperimentLogged")
  expect_identical(dim(filtered), c(10L, 5L))
  expect_true(length(filtered@log_history) == 1)
  expect_match(filtered@log_history[1], "filter: removed 5 samples \\(50%\\), 5 samples remaining")
})

test_that("filter tracks removal of rows (genes)", {
  # Create a simple SummarizedExperiment object with tidySummarizedExperiment
  skip_if_not_installed("tidySummarizedExperiment")
  
  library(tidySummarizedExperiment)
  
  counts <- matrix(rpois(100, 10), nrow = 10, ncol = 10)
  rownames(counts) <- paste0("gene", 1:10)
  colnames(counts) <- paste0("sample", 1:10)
  
  colData <- data.frame(
    condition = rep(c("treated", "control"), each = 5),
    batch = sample(1:3, 10, replace = TRUE)
  )
  
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(counts = counts),
    colData = colData
  )
  
  # Use tidy() instead of as_tibble()
  se_tidy <- tidySummarizedExperiment::tidy(se)
  
  # Log the object and filter
  logged_se <- log(se_tidy)
  filtered <- filter(logged_se, .feature %in% c("gene1", "gene2", "gene3"))
  
  # Tests
  expect_s4_class(filtered, "SummarizedExperimentLogged")
  expect_identical(dim(filtered)[1], 3L)
  expect_true(length(filtered@log_history) == 1)
  expect_match(filtered@log_history[1], "filter: removed 7 genes \\(70%\\), 3 genes remaining")
})

test_that("mutate tracks column modifications", {
  # Create a simple SummarizedExperiment object
  counts <- matrix(rpois(100, 10), nrow = 10, ncol = 10)
  rownames(counts) <- paste0("gene", 1:10)
  colnames(counts) <- paste0("sample", 1:10)
  
  colData <- data.frame(
    condition = rep(c("treated", "control"), each = 5),
    batch = sample(1:3, 10, replace = TRUE)
  )
  
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(counts = counts),
    colData = colData
  )
  
  # Log the object and mutate
  logged_se <- log(se)
  mutated <- mutate(logged_se, new_col = batch * 2)
  
  # Tests
  expect_s4_class(mutated, "SummarizedExperimentLogged")
  expect_true("new_col" %in% colnames(colData(mutated)))
  expect_true(length(mutated@log_history) == 1)
  expect_match(mutated@log_history[1], "mutate: added 1 new column\\(s\\): new_col")
}) 