#' @importFrom methods setMethod callNextMethod new setClass
NULL


.onLoad <- function(libname, pkgname) {
  # packageStartupMessage("Welcome to omicslog: Logging for High-Throughput Omics Data Analysis")

  # Check if either tidySummarizedExperiment or tidySingleCellExperiment is loaded
  loaded_pkgs <- loadedNamespaces()
  # message("Currently loaded packages: ", paste(loaded_pkgs, collapse = ", "))
  
  if (!any(c("tidySummarizedExperiment", "tidySingleCellExperiment") %in% loaded_pkgs)) {
    packageStartupMessage(
      "\nWARNING: It is recommended to load omicslog AFTER loading tidySummarizedExperiment or tidySingleCellExperiment.\n",
      "This ensures proper method dispatch for dplyr verbs like filter() and mutate().\n",
      "If you've already loaded these packages, you can call reexport_omicslog_methods()\n",
      "to ensure omicslog's methods take precedence.\n"
    )
  }
} 