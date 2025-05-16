#' SummarizedExperimentLogged class
#'
#' A class extending SummarizedExperiment to include logging capabilities.
#' This class tracks operations performed on the object and displays a
#' log when the object is printed.
#'
#' @slot log_history Character vector storing the history of operations
#' @exportClass SummarizedExperimentLogged
#' @import methods
#' @import SummarizedExperiment
setClass("SummarizedExperimentLogged",
         contains = "SummarizedExperiment",
         slots = list(
           log_history = "character"
         )) 