# Re-export the tidy verbs so library(omicslog) alone puts them on the search
# path, instead of falling back to e.g. stats::filter.

#' @importFrom dplyr filter
#' @export
dplyr::filter

#' @importFrom dplyr mutate
#' @export
dplyr::mutate

#' @importFrom dplyr select
#' @export
dplyr::select

#' @importFrom dplyr slice
#' @export
dplyr::slice

#' @importFrom tidyr extract
#' @export
tidyr::extract
