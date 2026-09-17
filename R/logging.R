# Helper functions for logging
.get_timestamp <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}

.format_log_message <- function(operation, message) {
  ts <- .get_timestamp()
  list(
    Time = ts,
    Operation = operation, Message = message
  )
}

.update_log_history <- function(result, original, messages) {
  if (length(messages) > 0) {
    result@log_history <- dplyr::bind_rows(original@log_history, dplyr::bind_rows(messages))
  } else {
    result@log_history <- original@log_history
  }
  return(result)
}

.log_dimension_changes <- function(pre_dim, post_dim, operation) {
  msgs <- list()

  if (pre_dim[1] != post_dim[1]) {
    genes_removed <- pre_dim[1] - post_dim[1]
    percent_removed <- round(genes_removed / pre_dim[1] * 100)
    msgs <- c(msgs, list(.format_log_message(operation,
     paste0("removed ", genes_removed, " gene(s) (", percent_removed, "%), ",
             post_dim[1], " gene(s) remaining"))))
  }

  if (pre_dim[2] != post_dim[2]) {
    samples_removed <- pre_dim[2] - post_dim[2]
    percent_removed <- round(samples_removed / pre_dim[2] * 100)
    msgs <- c(msgs, list(.format_log_message(operation,
      paste0("removed ", samples_removed, " sample(s) (", percent_removed, "%), ",
             post_dim[2], " sample(s) remaining"))))
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
#' @return A SummarizedExperimentLogged object with tracking capabilities
#' @importFrom tibble tibble
#' @export
#' @examples
#' if (requireNamespace("tidySummarizedExperiment", quietly = TRUE)) {
#'   se <- tidySummarizedExperiment::pasilla
#'   se_logged <- log_start(se)
#'   result <- se_logged |>
#'     filter(condition == "treated")
#' }
log_start <- function(se) {
  if (!inherits(se, "SummarizedExperiment")) {
    stop("Input must be a SummarizedExperiment or subclass.")
  }
  new("SummarizedExperimentLogged", se, log_history = tibble(Time = character(),
  Operation = character(), Message = character()))
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
    n_logs <- object@log_history |> head()
    log_lines <- paste0(
      "[", n_logs$Time, "] ",
      n_logs$Operation, ": ",
      n_logs$Message, collapse = "\n")
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
setMethod("filter", signature = signature(.data = "SummarizedExperimentLogged"),
          definition = function(.data, ...) {
          
            # Get dimensions before filtering
            pre_dim <- dim(.data)

            # Drop down to plain SE so dispatch goes to tidySummarizedExperiment's
            # filter.SummarizedExperiment method, not back to this one.
            se_plain  <- as(.data, "SummarizedExperiment", strict = TRUE)
            filtered  <- dplyr::filter(se_plain, ...)

            # Re-wrap as SummarizedExperimentLogged, preserving log_history explicitly.
            result <- new("SummarizedExperimentLogged",
                          filtered,
                          log_history = .data@log_history)

            # Get dimensions after filtering
            post_dim <- dim(result)

            # Generate log messages for dimension changes
            msgs <- .log_dimension_changes(pre_dim, post_dim, "filter")

            # Update log history
            return(.update_log_history(result, .data, msgs))
          })

#' Modify columns of a SummarizedExperimentLogged object
#'
#' @rdname mutate
#' @param .data A SummarizedExperimentLogged object
#' @param ... Name-value pairs of expressions used to modify columns
#' @importFrom dplyr mutate
#' @importFrom rlang enquos
#' @export

setMethod("mutate", signature = signature(.data = "SummarizedExperimentLogged"),
          definition = function(.data, ...) {
            # Capture the pre-mutation state
            pre_cols_data <- colnames(colData(.data))
            pre_assay_names <- names(assays(.data))
            
            # Capture all the expressions being used in mutate
            dots <- rlang::enquos(...)
            mut_names <- names(dots)
            
            # Drop down to plain SE so dispatch goes to tidySummarizedExperiment's
            # filter.SummarizedExperiment method, not back to this one.
            se_plain  <- as(.data, "SummarizedExperiment", strict = TRUE)
            mutated  <- dplyr::mutate(se_plain, ...)

            # Re-wrap as SummarizedExperimentLogged, preserving log_history explicitly.
            result <- new("SummarizedExperimentLogged",
                          mutated,
                          log_history = .data@log_history)
            
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
              msg <- .format_log_message(operation="mutate", message=paste0("added ", length(new_cols), " new column(s): ",
             paste(new_cols, collapse = ", ")))
            } else if (length(modified_cols) > 0) {
              msg <- .format_log_message(operation="mutate", message=paste0("modified column(s): ", paste(modified_cols, collapse = ", ")))
            } else {
              # No changes detected, preserve log history
              return(.update_log_history(result, .data, character(0)))
            }
            
            # Update log history
            return(.update_log_history(result, .data, msg))
          }) 

#' Filter columns of a SummarizedExperimentLogged object
#' 
#' @rdname select
#' @param .data A SummarizedExperimentLogged object
#' @param ... Name of columns to select or deselect
#' @importFrom dplyr select
#' @export
setMethod("select", signature = signature(.data = "SummarizedExperimentLogged"),
          definition = function(.data, ...) {
            # Get dimensions before filtering
            pre_cols_data <- colnames(colData(.data))
            
            # Apply the filter
            se_plain  <- as(.data, "SummarizedExperiment", strict = TRUE)
            selected  <- dplyr::select(se_plain, ...)

            # Re-wrap as SummarizedExperimentLogged, preserving log_history explicitly.
            result <- new("SummarizedExperimentLogged",
                          selected,
                          log_history = .data@log_history)
            
            # Get dimensions after filtering
            post_cols_data <- colnames(colData(result))
            
            diff <- length(pre_cols_data) - length(post_cols_data)
            
            # Generate log message
            if (diff > 0) {
              msgs <- .format_log_message(operation="select", 
              message=paste0("removed ", diff , " (",round((diff / length(pre_cols_data)) * 100),"%), ",
                     length(post_cols_data), " column(s) remaining"
                     ))
            } else {
              # No changes detected, preserve log history
              return(.update_log_history(result, .data, character(0)))
            }
            
            # Update log history
            return(.update_log_history(result, .data, msgs))
          })

#' Extract values from a column into multiple columns in a SummarizedExperimentLogged object
#'
#' @rdname extract
#' @param .data A SummarizedExperimentLogged object
#' @param col Column to extract from
#' @param into Names of new variables to create
#' @param regex A regular expression to extract values
#' @param remove If TRUE, remove input column from output
#' @param convert If TRUE, runs type.convert() on each new column
#' @param ... Additional arguments passed to tidyr::extract
#' @importFrom tidyr extract
#' @importFrom rlang enquo as_name
#' @export
setMethod("extract",
          signature = signature(
            data = "SummarizedExperimentLogged",
            col = "ANY",
            into = "ANY",
            regex = "ANY",
            remove = "ANY",
            convert = "ANY"
          ),
          function(data, col, into, regex = "([[:alnum:]]+)", 
                   remove = TRUE, convert = FALSE, ...) {
            
            # Capture pre-state
            pre_cols <- colnames(colData(data))
            col_name <- rlang::as_name(rlang::enquo(col))
            
            # Perform extraction using tidyr's method
            se_plain  <- as(data, "SummarizedExperiment", strict = TRUE)
            colData(se_plain) <- colData(se_plain) |> as.data.frame() |>
              tidyr::extract({{ col }}, into, regex,
                                     remove = remove, convert = convert, ...) |>
              S4Vectors::DataFrame()

            result <- new("SummarizedExperimentLogged",
                          se_plain,
                          log_history = data@log_history)
            
            # Capture post-state
            post_cols <- colnames(colData(result))
            new_cols <- setdiff(post_cols, pre_cols)
            
            # Generate log message
            if (length(new_cols) > 0) {
              msg <- .format_log_message(operation="extract", 
              message=sprintf("extracted '%s' into %s: %s%s",
                        col_name,
                        ifelse(length(new_cols) > 1, "columns", "column"),
                        paste(new_cols, collapse = ", "),
                        if (remove && col_name %in% post_cols) "" 
                        else if (remove) " (original removed)" 
                        else " (original kept)"))
              return(.update_log_history(result, data, msg))
            }
            
            return(.update_log_history(result, data, character(0)))
          })


#' Slice rows from a SummarizedExperimentLogged object
#' 
#' @rdname slice
#' @param .data A SummarizedExperimentLogged object
#' @param ... Row selection expressions
#' @param .preserve If TRUE, preserves the grouping structure of the data
#' @importFrom dplyr slice
#' @importFrom rlang enquos
#' @importFrom tibble as_tibble
#' @export
setGeneric("slice", function(.data, ..., .preserve = FALSE) standardGeneric("slice"))
setMethod("slice",
          signature = signature(.data = "SummarizedExperimentLogged"),
          definition = function(.data, ..., .preserve = FALSE) {
            
            # Capture pre-state
            pre_nrow <- as_tibble(.data) |> nrow()
            pre_rownames <- rownames(.data)
            
            se_plain  <- as(.data, "SummarizedExperiment", strict = TRUE)
            sliced  <- dplyr::slice(se_plain, ..., .preserve = .preserve)

            # Re-wrap as SummarizedExperimentLogged, preserving log_history explicitly.
            result <- new("SummarizedExperimentLogged",
                          sliced,
                          log_history = .data@log_history)
            
            # Capture post-state
            post_nrow <- as_tibble(result) |> nrow()
            post_rownames <- rownames(result)
            
            # Generate log message if rows were removed
            if (pre_nrow != post_nrow) {
              removed <- setdiff(pre_rownames, post_rownames)
              n_removed <- pre_nrow - post_nrow
              msg <- .format_log_message(operation="slice",
                message=sprintf("kept %d/%d rows (%.1f%%)%s",
                        post_nrow, pre_nrow,
                        100 * post_nrow / pre_nrow,
                        paste("; removed", n_removed, "rows"))
              )
            } else {
              msg <- character(0)
            }
            
            # Update log history
            .update_log_history(result, .data, msg)
          })