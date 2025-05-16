#' @importFrom methods setMethod callNextMethod new setClass
NULL

.onLoad <- function(libname, pkgname) {
  # Register S3 methods for dplyr verbs if not already registered
  if (!isGeneric("filter")) {
    setGeneric("filter", function(.data, ...) standardGeneric("filter"))
  }
  
  if (!isGeneric("mutate")) {
    setGeneric("mutate", function(.data, ...) standardGeneric("mutate"))
  }
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to omiclog: Logging for High-Throughput Omics Data Analysis")
} 