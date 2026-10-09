test_that("tidy verbs keep SingleCellExperimentLogged and log changes", {
  sce_logged <- logged_pbmc()
  n_g1 <- sum(sce_logged$groups == "g1")

  result <- filter(sce_logged, groups == "g1")
  expect_s4_class(result, "SingleCellExperimentLogged")
  expect_equal(ncol(result), n_g1)
  expect_match(
    log_lines(result),
    paste0("^filter: removed ", ncol(sce_logged) - n_g1, " observation\\(s\\)")
  )

  result <- mutate(result, double_count = nCount_RNA * 2)
  expect_s4_class(result, "SingleCellExperimentLogged")
  expect_true("double_count" %in% colnames(colData(result)))
  expect_equal(
    log_lines(result)[2],
    "mutate: added 1 new column(s): double_count"
  )

  result <- slice(result, 1:5)
  expect_s4_class(result, "SingleCellExperimentLogged")
  expect_equal(ncol(result), 5)
  expect_match(log_lines(result)[3], paste0("^slice: kept 5/", n_g1, " rows"))
})

test_that("tidy verbs keep reducedDims", {
  sce_logged <- logged_pbmc()
  result <- filter(sce_logged, groups == "g1")
  expect_equal(reducedDimNames(result), reducedDimNames(sce_logged))
  expect_equal(nrow(reducedDim(result, "PCA")), ncol(result))
})

test_that("[ works on SingleCellExperimentLogged", {
  sce_logged <- logged_pbmc()
  result <- sce_logged[1:10, 1:20]
  expect_s4_class(result, "SingleCellExperimentLogged")
  expect_equal(dim(result), c(10L, 20L))
  expect_equal(nrow(result@log_history), 2)
})

test_that("$<- and colData<- work on SingleCellExperimentLogged", {
  sce_logged <- logged_pbmc()

  sce_logged$new_col <- "a"
  expect_s4_class(sce_logged, "SingleCellExperimentLogged")
  expect_equal(log_lines(sce_logged), "colData<-: added new column 'new_col'")

  colData(sce_logged)$groups <- toupper(colData(sce_logged)$groups)
  expect_equal(
    log_lines(sce_logged)[2],
    "colData<-: modified column 'groups'"
  )
})

test_that("rowData<- works on SingleCellExperimentLogged", {
  sce_logged <- logged_pbmc()

  rowData(sce_logged)$is_mito <- grepl("^MT-", rownames(sce_logged))
  expect_s4_class(sce_logged, "SingleCellExperimentLogged")
  expect_true("is_mito" %in% colnames(rowData(sce_logged)))
  expect_equal(
    log_lines(sce_logged),
    "rowData<-: added 1 new column(s): is_mito"
  )
})

test_that("assays<- works on SingleCellExperimentLogged", {
  sce_logged <- logged_pbmc()

  assays(sce_logged)$log2_counts <- log2(assay(sce_logged, "counts") + 1)
  expect_s4_class(sce_logged, "SingleCellExperimentLogged")
  expect_equal(
    log_lines(sce_logged),
    "assays<-: added 1 new assay(s): log2_counts"
  )
})

test_that("reducedDim<- logs added and modified dimensions", {
  sce_logged <- logged_pbmc()
  pca <- reducedDim(sce_logged, "PCA")

  reducedDim(sce_logged, "PCA2") <- pca[, 1:2]
  expect_true("PCA2" %in% reducedDimNames(sce_logged))
  expect_equal(
    log_lines(sce_logged),
    "reducedDim<-: added new reduced dimension 'PCA2' (2 dimension(s))"
  )

  reducedDim(sce_logged, "PCA") <- pca * 2
  expect_equal(
    log_lines(sce_logged)[2],
    "reducedDim<-: modified reduced dimension 'PCA'"
  )

  # Assigning an identical matrix is not logged
  reducedDim(sce_logged, "PCA2") <- reducedDim(sce_logged, "PCA2")
  expect_equal(nrow(sce_logged@log_history), 2)
})

test_that("reducedDims<- logs added and modified dimensions together", {
  sce_logged <- logged_pbmc()

  rd <- reducedDims(sce_logged)
  rd$UMAP <- rd$PCA[, 1:2]
  rd$TSNE <- abs(rd$TSNE)
  reducedDims(sce_logged) <- rd

  expect_equal(log_lines(sce_logged), c(
    "reducedDims<-: added 1 new reduced dimension(s): UMAP",
    "reducedDims<-: modified reduced dimension 'TSNE'"
  ))
})
