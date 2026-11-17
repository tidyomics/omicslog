#' SummarizedExperimentLogged class
#'
#' A class extending SummarizedExperiment to include logging capabilities.
#' This class tracks operations performed on the object and displays a
#' log when the object is printed.
#'
#' @slot log_history A data.frame storing the history of operations
#' @exportClass SummarizedExperimentLogged
#' @import methods
#' @import SummarizedExperiment
#' @examples
#' counts <- matrix(rpois(20, 10), nrow = 5,
#'                  dimnames = list(paste0("gene", 1:5), paste0("s", 1:4)))
#' se <- SummarizedExperiment(assays = list(counts = counts))
#' se_logged <- log_start(se)
#' is(se_logged, "SummarizedExperimentLogged")
#' se_logged[1:3, ]
setClass("SummarizedExperimentLogged",
         contains = "SummarizedExperiment",
         slots = list(
           log_history = "data.frame"
         ))

#' SingleCellExperimentLogged class
#'
#' A class extending SingleCellExperiment to include logging capabilities.
#' This class tracks operations performed on the object and displays a
#' log when the object is printed.
#'
#' @slot log_history A data.frame storing the history of operations
#' @exportClass SingleCellExperimentLogged
#' @import methods
#' @import SingleCellExperiment
#' @examples
#' counts <- matrix(rpois(40, 5), nrow = 5,
#'                  dimnames = list(paste0("gene", 1:5), paste0("cell", 1:8)))
#' sce <- SingleCellExperiment(assays = list(counts = counts))
#' sce_logged <- log_start(sce)
#' is(sce_logged, "SingleCellExperimentLogged")
#' sce_logged[, 1:4]
setClass("SingleCellExperimentLogged",
         contains = "SingleCellExperiment",
         slots = list(
           log_history = "data.frame"
         ))


#' ExperimentLogged class
#'
#' A class union of SummarizedExperimentLogged and SingleCellExperimentLogged,
#' used to define logging methods once for both classes.
#'
#' @exportClass ExperimentLogged
#' @examples
#' counts <- matrix(rpois(20, 10), nrow = 5)
#' se_logged <- log_start(SummarizedExperiment(assays = list(counts = counts)))
#' sce_logged <- log_start(SingleCellExperiment(assays = list(counts = counts)))
#' is(se_logged, "ExperimentLogged")
#' is(sce_logged, "ExperimentLogged")
setClassUnion("ExperimentLogged",
              c("SummarizedExperimentLogged", "SingleCellExperimentLogged"))
