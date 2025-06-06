# Helper functions for logging
.get_timestamp <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}

.format_log_message <- function(operation, message) {
  paste0("[", .get_timestamp(), "] ", operation, ": ", message)
}

.update_log_history <- function(result, original, messages) {
  if (length(messages) > 0) {
    result@log_history <- c(original@log_history, messages)
  } else {
    result@log_history <- original@log_history
  }
  return(result)
}

.log_dimension_changes <- function(pre_dim, post_dim, operation) {
  msgs <- character(0)
  
  # Check if rows (genes) changed
  if (pre_dim[1] != post_dim[1]) {
    genes_removed <- pre_dim[1] - post_dim[1]
    percent_removed <- round(genes_removed / pre_dim[1] * 100)
    msgs <- c(msgs, .format_log_message(operation, 
      paste0("removed ", genes_removed, " genes (", percent_removed, "%), ",
             post_dim[1], " genes remaining")))
  }
  
  # Check if columns (samples) changed
  if (pre_dim[2] != post_dim[2]) {
    samples_removed <- pre_dim[2] - post_dim[2]
    percent_removed <- round(samples_removed / pre_dim[2] * 100)
    msgs <- c(msgs, .format_log_message(operation,
      paste0("removed ", samples_removed, " samples (", percent_removed, "%), ",
             post_dim[2], " samples remaining")))
  }
  
  return(msgs)
}

#' Create a logging-enabled SummarizedExperiment object
#'
#' This function wraps a SummarizedExperiment object with logging capabilities.
#' Operations performed on the resulting object will be tracked and displayed
#' when the object is printed.
#'
#' @param se A SummarizedExperiment or derived object
#' @param to_conda A list with environment name (env_name) and file name (file) to export the YAML file.
#' @return A SummarizedExperimentLogged object with tracking capabilities
#' @export
#' @examples
#' if (requireNamespace("tidySummarizedExperiment", quietly = TRUE)) {
#'   se <- tidySummarizedExperiment::pasilla
#'   se_logged <- log_start(se)
#'   result <- se_logged |>
#'     filter(condition == "treated")
#' }
log_start <- function(se, to_conda = FALSE, to_docker = FALSE) {
  if (!inherits(se, "SummarizedExperiment")) {
    stop("Input must be a SummarizedExperiment or subclass.")
  }
  
  if(is.list(to_conda)){
    generate_conda_env_yml(env_name = to_conda$env_name, 
                           file = to_conda$file)
  }
  
  if(to_docker){
    generate_dockerfile()
  }
  
  new("SummarizedExperimentLogged", se, log_history = character(0))
}

#' @rdname log_start
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
  
  # Generate log messages for dimension changes
  msgs <- .log_dimension_changes(pre_dim, post_dim, "filter")
  
  # Update log history
  return(.update_log_history(result, .data, msgs))
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
  if (length(new_cols) > 0) {
    msg <- .format_log_message("mutate", 
      paste0("added ", length(new_cols), " new column(s): ",
             paste(new_cols, collapse = ", ")))
  } else if (length(modified_cols) > 0) {
    msg <- .format_log_message("mutate",
      paste0("modified column(s): ", paste(modified_cols, collapse = ", ")))
  } else {
    # No changes detected, preserve log history
    return(.update_log_history(result, .data, character(0)))
  }
  
  # Update log history
  return(.update_log_history(result, .data, msg))
}

#' @rdname mutate
#' @export
setMethod("mutate", signature = signature(.data = "SummarizedExperimentLogged"),
          definition = se_mutate) 