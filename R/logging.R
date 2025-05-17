#' Create a logging-enabled SummarizedExperiment object
#'
#' This function wraps a SummarizedExperiment object with logging capabilities.
#' Operations performed on the resulting object will be tracked and displayed
#' when the object is printed.
#'
#' @param se A SummarizedExperiment or derived object
#' @return A SummarizedExperimentLogged object with tracking capabilities
#' @export
#' @examples
#' if (requireNamespace("tidySummarizedExperiment", quietly = TRUE)) {
#'   se <- tidySummarizedExperiment::pasilla
#'   se_logged <- log(se)
#'   result <- se_logged |>
#'     filter(condition == "treated")
#' }
log <- function(se) {
  if (!inherits(se, "SummarizedExperiment")) {
    stop("Input must be a SummarizedExperiment or subclass.")
  }
  new("SummarizedExperimentLogged", se, log_history = character(0))
}

#' @rdname log
#' @param object A SummarizedExperimentLogged object
#' @export
setMethod("show", "SummarizedExperimentLogged", function(object) {
  # Call the parent show method first
  callNextMethod()

  # Then display the log history
  if (length(object@log_history) > 0) {
    # Create a formatted string for the log
    log_lines <- paste(object@log_history, collapse = "\n")
    log_output <- paste0("\nOperation log:\n", log_lines)
    
    # Use base R print for reliable output in both console and R Markdown
    cat(log_output, "\n")
  }
})

#' Filter rows and columns of a SummarizedExperimentLogged object
#'
#' @rdname filter
#' @param .data A SummarizedExperimentLogged object
#' @param ... Logical expressions used for filtering
#' @importFrom dplyr filter
#' @export
se_filter <- function(.data, ...) {
  # Normal filter for regular SummarizedExperiment
  if (!inherits(.data, "SummarizedExperimentLogged")) {
    return(filter(.data, ...))
  }
  
  # Get dimensions before filtering
  pre_dim <- dim(.data)
  
  # Apply the filter
  result <- callNextMethod(.data, ...)
  
  # Get dimensions after filtering
  post_dim <- dim(result)
  
  # Generate log message if dimensions changed
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  msg <- NULL
  
  # Check if rows (genes) changed
  if (pre_dim[1] != post_dim[1]) {
    genes_removed <- pre_dim[1] - post_dim[1]
    percent_removed <- round(genes_removed / pre_dim[1] * 100)
    msg <- paste0(
      "[", timestamp, "] ",
      "filter: removed ", genes_removed, " genes (", percent_removed, "%), ",
      post_dim[1], " genes remaining"
    )
  }
  
  # Check if columns (samples) changed
  if (pre_dim[2] != post_dim[2]) {
    samples_removed <- pre_dim[2] - post_dim[2]
    percent_removed <- round(samples_removed / pre_dim[2] * 100)
    msg <- paste0(
      "[", timestamp, "] ",
      "filter: removed ", samples_removed, " samples (", percent_removed, "%), ",
      post_dim[2], " samples remaining"
    )
  }
  
  # Add the message to log history if not NULL
  if (!is.null(msg)) {
    # cat(msg, "\n")  # Print to console
    result@log_history <- c(.data@log_history, msg)
  } else {
    # Preserve existing log history
    result@log_history <- .data@log_history
  }
  
  return(result)
}

#' @rdname filter
#' @export
setMethod("filter", signature = signature(.data = "SummarizedExperimentLogged"),
          definition = se_filter)

#' Modify columns of a SummarizedExperimentLogged object
#'
#' @rdname mutate
#' @param .data A SummarizedExperimentLogged object
#' @param ... Name-value pairs of expressions used to modify columns
#' @importFrom dplyr mutate
#' @importFrom rlang enquos
#' @export
se_mutate <- function(.data, ...) {
  # Normal mutate for regular SummarizedExperiment
  if (!inherits(.data, "SummarizedExperimentLogged")) {
    return(mutate(.data, ...))
  }
  
  # Capture the pre-mutation state
  pre_cols_data <- colnames(colData(.data))
  pre_assay_names <- names(assays(.data))
  
  # Capture all the expressions being used in mutate
  dots <- rlang::enquos(...)
  mut_names <- names(dots)
  
  # Apply the mutate
  result <- callNextMethod(.data, ...)
  
  # Capture the post-mutation state
  post_cols_data <- colnames(colData(result))
  post_assay_names <- names(assays(result))
  
  # Identify new columns
  new_cols_data <- setdiff(post_cols_data, pre_cols_data)
  new_assays <- setdiff(post_assay_names, pre_assay_names)
  
  # Combine all new columns
  new_cols <- c(new_cols_data, new_assays)
  
  # Identify modified columns (in mut_names but not in new_cols)
  modified_cols <- setdiff(mut_names, new_cols)
  
  # Generate log message
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  
  if (length(new_cols) > 0) {
    msg <- paste0(
      "[", timestamp, "] ",
      "mutate: added ", length(new_cols), " new column(s): ",
      paste(new_cols, collapse = ", ")
    )
  } else if (length(modified_cols) > 0) {
    # If no new columns but mutations were specified, these were modifications
    msg <- paste0(
      "[", timestamp, "] ",
      "mutate: modified column(s): ",
      paste(modified_cols, collapse = ", ")
    )
  } else {
    # No changes detected, preserve log history
    result@log_history <- .data@log_history
    return(result)
  }
  
  # Add the message to log history
  result@log_history <- c(.data@log_history, msg)
  return(result)
}

#' @rdname mutate
#' @export
setMethod("mutate", signature = signature(.data = "SummarizedExperimentLogged"),
          definition = se_mutate) 