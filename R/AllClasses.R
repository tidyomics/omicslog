#' SummarizedExperimentLogged class
#'
#' A class extending SummarizedExperiment to include logging capabilities.
#' This class tracks operations performed on the object and displays a
#' log when the object is printed.
#'
#' @slot log_history A tibble storing the history of operations
#' @exportClass SummarizedExperimentLogged
#' @import methods
#' @import SummarizedExperiment
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
#' @slot log_history A tibble storing the history of operations
#' @exportClass SingleCellExperimentLogged
#' @import methods
#' @import SingleCellExperiment
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
setClassUnion("ExperimentLogged",
              c("SummarizedExperimentLogged", "SingleCellExperimentLogged"))