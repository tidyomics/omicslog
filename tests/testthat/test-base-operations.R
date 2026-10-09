test_that("[ logs removed genes and samples as separate entries", {
  se_logged <- logged_pasilla()
  keep <- se_logged$condition == "treated"

  result <- se_logged[1:10, ]
  expect_s4_class(result, "SummarizedExperimentLogged")
  expect_equal(dim(result), c(10L, ncol(se_logged)))
  expect_equal(nrow(result@log_history), 1)
  expect_match(log_lines(result), "^subset: removed \\d+ features")

  result <- se_logged[, keep]
  expect_equal(nrow(result), nrow(se_logged))
  expect_equal(nrow(result@log_history), 1)
  expect_match(log_lines(result), "^subset: removed \\d+ observations")

  result <- se_logged[1:5, keep]
  expect_equal(dim(result), c(5L, sum(keep)))
  expect_equal(nrow(result@log_history), 2)
  expect_match(log_lines(result)[1], "^subset: removed \\d+ features")
  expect_match(log_lines(result)[2], "^subset: removed \\d+ observations")
})

test_that("[ without dimension changes adds no log entry", {
  se_logged <- logged_pasilla()
  result <- se_logged[seq_len(nrow(se_logged)), ]
  expect_equal(dim(result), dim(se_logged))
  expect_equal(nrow(result@log_history), 0)
})

test_that("[ keeps earlier log entries", {
  se_logged <- logged_pasilla()[1:10, ]
  result <- se_logged[1:5, ]
  expect_equal(nrow(result@log_history), 2)
})

test_that("$<- logs new and modified columns", {
  se_logged <- logged_pasilla()

  se_logged$new_col <- rep("test", ncol(se_logged))
  expect_true("new_col" %in% colnames(colData(se_logged)))
  expect_equal(log_lines(se_logged), "colData<-: added new column 'new_col'")

  original <- se_logged$condition
  se_logged$condition <- toupper(original)
  expect_false(identical(se_logged$condition, original))
  expect_equal(
    log_lines(se_logged)[2],
    "colData<-: modified column 'condition'"
  )
})

test_that("colData<- logs added and modified columns", {
  se_logged <- logged_pasilla()

  cd <- colData(se_logged)
  cd$new_column <- rep("test", ncol(se_logged))
  colData(se_logged) <- cd
  expect_true("new_column" %in% colnames(colData(se_logged)))
  expect_equal(
    log_lines(se_logged),
    "colData<-: added 1 new column(s): new_column"
  )

  cd <- colData(se_logged)
  cd$condition <- toupper(cd$condition)
  colData(se_logged) <- cd
  expect_equal(
    log_lines(se_logged)[2],
    "colData<-: modified column 'condition'"
  )
})

test_that("colData<- logs several changes in one assignment", {
  se_logged <- logged_pasilla()

  cd <- colData(se_logged)
  cd$new_column <- "test"
  cd$condition <- toupper(cd$condition)
  cd$type <- toupper(cd$type)
  colData(se_logged) <- cd

  expect_equal(log_lines(se_logged), c(
    "colData<-: added 1 new column(s): new_column",
    "colData<-: modified column 'condition'",
    "colData<-: modified column 'type'"
  ))
})

test_that("colData<- without changes adds no log entry", {
  se_logged <- logged_pasilla()
  colData(se_logged) <- colData(se_logged)
  expect_equal(nrow(se_logged@log_history), 0)
})

test_that("rowData<- logs added and modified columns", {
  se_logged <- logged_pasilla()

  rowData(se_logged)$is_first <- seq_len(nrow(se_logged)) == 1
  expect_true("is_first" %in% colnames(rowData(se_logged)))
  expect_s4_class(se_logged, "SummarizedExperimentLogged")
  expect_equal(
    log_lines(se_logged),
    "rowData<-: added 1 new column(s): is_first"
  )

  rowData(se_logged)$is_first <- !rowData(se_logged)$is_first
  expect_equal(
    log_lines(se_logged)[2],
    "rowData<-: modified column 'is_first'"
  )
})

test_that("assays<- logs added and modified assays", {
  se_logged <- logged_pasilla()

  assays(se_logged)$log_counts <- log2(assay(se_logged, "counts") + 1)
  expect_true("log_counts" %in% assayNames(se_logged))
  expect_equal(
    log_lines(se_logged),
    "assays<-: added 1 new assay(s): log_counts"
  )

  assays(se_logged)$log_counts <- assay(se_logged, "log_counts") * 2
  expect_equal(
    log_lines(se_logged)[2],
    "assays<-: modified assay 'log_counts'"
  )
})
