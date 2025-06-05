test_that("colData column modification works correctly", {
  # Skip if tidySummarizedExperiment is not available
  skip_if_not_installed("tidySummarizedExperiment")
  
  # Create a test object
  se <- tidySummarizedExperiment::pasilla
  se_logged <- log_start(se)
  
  # Test adding a new column
  cd <- colData(se_logged)
  cd$new_column <- rep("test", ncol(se_logged))
  colData(se_logged) <- cd
  
  # Add diagnostic output after each colData modification
  print("After adding new_column:")
  print(se_logged@log_history)
  print(colnames(colData(se_logged)))
  print(class(colData(se_logged)))
  
  # Verify the column was added
  expect_true("new_column" %in% colnames(colData(se_logged)))
  expect_equal(length(se_logged@log_history), 1)
  expect_true(grepl("colData<-: added 1 new column\\(s\\): new_column", se_logged@log_history[1]))
  
  # Test modifying an existing column
  original_condition <- colData(se_logged)$condition
  cd <- colData(se_logged)
  cd$condition <- toupper(original_condition)
  colData(se_logged) <- cd
  
  # Add diagnostic output after each colData modification
  print("After modifying condition:")
  print(se_logged@log_history)
  print(colData(se_logged)$condition)
  print(original_condition)
  print(class(colData(se_logged)))
  
  # Verify the column was modified
  expect_equal(length(se_logged@log_history), 2)
  expect_true(grepl("colData<-: modified column 'condition'", se_logged@log_history[2]))
  expect_false(identical(colData(se_logged)$condition, original_condition))
  
  # Test modifying the same column again
  cd <- colData(se_logged)
  cd$new_column <- rep("test2", ncol(se_logged))
  colData(se_logged) <- cd
  
  # Add diagnostic output after each colData modification
  print("After modifying new_column:")
  print(se_logged@log_history)
  print(colData(se_logged)$new_column)
  print(class(colData(se_logged)))
  
  # Verify the modification was logged
  expect_equal(length(se_logged@log_history), 3)
  expect_true(grepl("colData<-: modified column 'new_column'", se_logged@log_history[3]))
})

test_that("colData<- works with both DataFrame and DFrame", {
  skip_if_not_installed("tidySummarizedExperiment")
  
  se <- tidySummarizedExperiment::pasilla
  se_logged <- log_start(se)
  
  # Test with DataFrame
  cd <- colData(se_logged)
  cd$test_col1 <- rep("test1", ncol(se_logged))
  colData(se_logged) <- cd
  expect_true("test_col1" %in% colnames(colData(se_logged)))
  expect_true(grepl("colData<-: added 1 new column\\(s\\): test_col1", se_logged@log_history[1]))
  
  # Test with DFrame
  cd <- as(cd, "DFrame")
  cd$test_col2 <- rep("test2", ncol(se_logged))
  colData(se_logged) <- cd
  expect_true("test_col2" %in% colnames(colData(se_logged)))
  expect_true(grepl("colData<-: added 1 new column\\(s\\): test_col2", se_logged@log_history[2]))
})

test_that("$<- operator works correctly", {
  skip_if_not_installed("tidySummarizedExperiment")
  
  se <- tidySummarizedExperiment::pasilla
  se_logged <- log_start(se)
  
  # Test adding new column
  se_logged$new_col <- rep("test", ncol(se_logged))
  expect_true("new_col" %in% colnames(colData(se_logged)))
  expect_true(grepl("colData<-: added new column 'new_col'", se_logged@log_history[1]))
  
  # Test modifying existing column
  original_condition <- se_logged$condition
  se_logged$condition <- toupper(original_condition)
  expect_true(grepl("colData<-: modified column 'condition'", se_logged@log_history[2]))
  expect_false(identical(se_logged$condition, original_condition))
}) 
