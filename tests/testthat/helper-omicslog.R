# Log entries as "Operation: Message" strings, in order
log_lines <- function(x) {
  paste0(x@log_history$Operation, ": ", x@log_history$Message)
}

# Logged SummarizedExperiment (pasilla: 14599 genes x 7 samples)
logged_pasilla <- function() {
  skip_if_not_installed("tidySummarizedExperiment")
  log_start(tidySummarizedExperiment::pasilla)
}

# Logged SingleCellExperiment (pbmc_small: 230 genes x 80 cells)
logged_pbmc <- function() {
  skip_if_not_installed("tidySingleCellExperiment")
  # Load the namespace so its dplyr methods for SingleCellExperiment exist
  requireNamespace("tidySingleCellExperiment", quietly = TRUE)
  env <- new.env()
  utils::data("pbmc_small", package = "tidySingleCellExperiment", envir = env)
  log_start(env$pbmc_small)
}
