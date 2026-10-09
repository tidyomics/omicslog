test_that("log_start creates the right class with an empty log", {
  se_logged <- logged_pasilla()
  expect_s4_class(se_logged, "SummarizedExperimentLogged")
  expect_s4_class(se_logged, "ExperimentLogged")
  expect_named(se_logged@log_history, c("Time", "Operation", "Message"))
  expect_equal(nrow(se_logged@log_history), 0)

  sce_logged <- logged_pbmc()
  expect_s4_class(sce_logged, "SingleCellExperimentLogged")
  expect_s4_class(sce_logged, "ExperimentLogged")
  expect_equal(nrow(sce_logged@log_history), 0)
})

test_that("log_start rejects objects that are not SummarizedExperiment", {
  expect_error(log_start(data.frame(a = 1)), "SummarizedExperiment")
})

test_that("show prints the operation log only when there is one", {
  se_logged <- logged_pasilla()
  expect_false(any(grepl("Operation log", capture.output(show(se_logged)))))

  se_logged <- se_logged[1:10, ]
  out <- capture.output(show(se_logged))
  expect_true(any(grepl("class: SummarizedExperimentLogged", out)))
  expect_true(any(grepl("Operation log", out)))
  expect_true(any(grepl("subset: removed", out)))
})

test_that("show uses the SingleCellExperiment printer for SCE objects", {
  sce_logged <- logged_pbmc()[1:10, ]
  out <- capture.output(show(sce_logged))
  expect_true(any(grepl("reducedDimNames", out)))
  expect_true(any(grepl("Operation log", out)))
})

test_that("filter logs removed samples and features", {
  se_logged <- logged_pasilla()
  n_treated <- sum(se_logged$condition == "treated")
  n_removed <- ncol(se_logged) - n_treated

  result <- filter(se_logged, condition == "treated")
  expect_s4_class(result, "SummarizedExperimentLogged")
  expect_equal(ncol(result), n_treated)
  expect_equal(nrow(result@log_history), 1)
  expect_match(
    log_lines(result),
    paste0("^filter: removed ", n_removed, " observation\\(s\\)")
  )

  result <- filter(result, .feature == "FBgn0000003")
  expect_equal(nrow(result), 1)
  expect_equal(nrow(result@log_history), 2)
  expect_match(log_lines(result)[2], "^filter: removed \\d+ feature\\(s\\)")
})

test_that("filter that keeps everything adds no log entry", {
  se_logged <- logged_pasilla()
  result <- filter(se_logged, !is.na(condition))
  expect_equal(dim(result), dim(se_logged))
  expect_equal(nrow(result@log_history), 0)
})

test_that("mutate logs new and modified columns", {
  se_logged <- logged_pasilla()

  result <- mutate(se_logged, log_counts = log2(counts + 1))
  expect_true("log_counts" %in% assayNames(result))
  expect_equal(
    log_lines(result),
    "mutate: added 1 new column(s): log_counts"
  )

  result <- mutate(result, condition = toupper(condition))
  expect_equal(
    log_lines(result)[2],
    "mutate: modified column(s): condition"
  )
})

test_that("select logs removed colData columns", {
  se_logged <- logged_pasilla()
  n_cols <- ncol(colData(se_logged))

  result <- select(se_logged, !type)
  expect_false("type" %in% colnames(colData(result)))
  expect_equal(nrow(result@log_history), 1)
  expect_match(
    log_lines(result),
    paste0("^select: removed 1 .*", n_cols - 1, " column\\(s\\) remaining")
  )
})

test_that("extract logs the new columns", {
  se_logged <- logged_pasilla()

  result <- extract(
    se_logged,
    col = type, into = c("fragment", "end"),
    regex = "([[:alnum:]]+)_([[:alnum:]]+)"
  )
  expect_true(all(c("fragment", "end") %in% colnames(colData(result))))
  expect_false("type" %in% colnames(colData(result)))
  expect_equal(
    log_lines(result),
    "extract: extracted 'type' into columns: fragment, end (original removed)"
  )
})

test_that("slice logs kept rows", {
  se_logged <- logged_pasilla()
  result <- slice(se_logged, 1)
  expect_s4_class(result, "SummarizedExperimentLogged")
  expect_equal(nrow(result@log_history), 1)
  expect_match(log_lines(result), "^slice: kept 1/\\d+ rows")
})

test_that("a full tidy pipeline keeps the log in order", {
  result <- logged_pasilla() |>
    extract(
      col = type, into = c("fragment", "end"),
      regex = "([[:alnum:]]+)_([[:alnum:]]+)"
    ) |>
    select(!end) |>
    filter(condition == "treated") |>
    mutate(log_counts = log2(counts + 1)) |>
    filter(.feature == "FBgn0000003") |>
    slice(3)

  expect_s4_class(result, "SummarizedExperimentLogged")
  expect_true("log_counts" %in% assayNames(result))
  expect_equal(
    result@log_history$Operation,
    c("extract", "select", "filter", "mutate", "filter", "slice")
  )
})
