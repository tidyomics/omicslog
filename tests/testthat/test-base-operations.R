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
  expect_true(grepl("colData<-: added 1 new column(s): new_column", se_logged@log_history[1]))
  
  # Test modifying an existing column
  original_condition <- colData(se_logged)$condition
  cd <- colData(se_logged)
  cd$condition <- tolower(original_condition)
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
