#' Subset a SummarizedExperimentLogged object
#'
#' @rdname subset
#' @param x A SummarizedExperimentLogged object
#' @param i,j,... Indices for subsetting
#' @export
setMethod("[", signature = signature(x = "SummarizedExperimentLogged"),
          function(x, i, j, ...) {
            # Get dimensions before subsetting
            pre_dim <- dim(x)
            
            # Apply the subsetting
            result <- callNextMethod(x, i, j, ...)
            
            # If result is not a SummarizedExperimentLogged, return as is
            if (!inherits(result, "SummarizedExperimentLogged")) {
              return(result)
            }
            
            # Get dimensions after subsetting
            post_dim <- dim(result)
            
            # Generate log message if dimensions changed
            timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
            msgs <- character(0)
            
            # Check if rows (genes) changed
            if (pre_dim[1] != post_dim[1]) {
              genes_removed <- pre_dim[1] - post_dim[1]
              percent_removed <- round(genes_removed / pre_dim[1] * 100)
              msgs <- c(msgs, paste0(
                "[", timestamp, "] ",
                "subset: removed ", genes_removed, " genes (", percent_removed, "%), ",
                post_dim[1], " genes remaining"
              ))
            }
            
            # Check if columns (samples) changed
            if (pre_dim[2] != post_dim[2]) {
              samples_removed <- pre_dim[2] - post_dim[2]
              percent_removed <- round(samples_removed / pre_dim[2] * 100)
              msgs <- c(msgs, paste0(
                "[", timestamp, "] ",
                "subset: removed ", samples_removed, " samples (", percent_removed, "%), ",
                post_dim[2], " samples remaining"
              ))
            }
            
            # Add the messages to log history if any
            if (length(msgs) > 0) {
              result@log_history <- c(x@log_history, msgs)
            } else {
              # Preserve existing log history
              result@log_history <- x@log_history
            }
            
            return(result)
})

#' @importFrom S4Vectors colData
#' @importFrom S4Vectors colData<-
#' @importFrom BiocGenerics colnames
#' @export
#' @examples
#' # Create a logged SummarizedExperiment
#' if (requireNamespace("tidySummarizedExperiment", quietly = TRUE)) {
#'   se <- tidySummarizedExperiment::pasilla
#'   se_logged <- log_start(se)
#'   
#'   # Modify existing column
#'   colData(se_logged)$condition <- tolower(colData(se_logged)$condition)
#'   
#'   # Add new column
#'   colData(se_logged)$new_column <- rep("test", ncol(se_logged))
#'   
#'   # Print to see the log
#'   se_logged
#' }

#' @export
setMethod("$<-", signature = signature(x = "SummarizedExperimentLogged"),
          function(x, name, value) {
            # Check if column exists
            is_new_column <- !(name %in% colnames(colData(x)))
            
            # Apply the modification using parent class method
            result <- callNextMethod(x, name, value)
            
            # Generate log message
            timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
            if (is_new_column) {
              msg <- paste0(
                "[", timestamp, "] ",
                "colData<-: added new column '", name, "'"
              )
            } else {
              msg <- paste0(
                "[", timestamp, "] ",
                "colData<-: modified column '", name, "'"
              )
            }
            
            # Add the message to log history
            result@log_history <- c(x@log_history, msg)
            return(result)
          })

#' @rdname colData
#' @export
setMethod("colData<-", signature = signature(x = "SummarizedExperimentLogged", value = "DataFrame"),
          function(x, value) {
            # Get original column names and values
            original_cols <- colnames(colData(x))
            original_values <- lapply(original_cols, function(col) colData(x)[[col]])
            names(original_values) <- original_cols
            
            # Get new column names
            new_cols <- colnames(value)
            
            # Find added and modified columns
            added_cols <- setdiff(new_cols, original_cols)
            existing_cols <- intersect(new_cols, original_cols)
            
            # Check for modifications in existing columns
            modified_cols <- character(0)
            for (col in existing_cols) {
              if (!identical(value[[col]], original_values[[col]])) {
                modified_cols <- c(modified_cols, col)
              }
            }
            
            # Generate log messages
            timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
            log_messages <- character(0)
            
            # Log added columns (all in one message, capitalized, plural, colon)
            if (length(added_cols) > 0) {
              msg <- paste0(
                "[", timestamp, "] ",
                "colData<-: added ", length(added_cols), " new column(s): ",
                paste(added_cols, collapse = ", ")
              )
              log_messages <- c(log_messages, msg)
            }
            
            # Log modified columns (one per column)
            if (length(modified_cols) > 0) {
              for (col in modified_cols) {
                msg <- paste0(
                  "[", timestamp, "] ",
                  "colData<-: modified column '", col, "'"
                )
                log_messages <- c(log_messages, msg)
              }
            }
            
            # Update the object
            x@colData <- value
            
            # Update log history if there were changes
            if (length(log_messages) > 0) {
              x@log_history <- c(x@log_history, log_messages)
            }
            
            return(x)
          })

#' @rdname colData
#' @export
setMethod("colData<-", signature = signature(x = "SummarizedExperimentLogged", value = "DFrame"),
          function(x, value) {
            # Get original column names and values
            original_cols <- colnames(colData(x))
            original_values <- lapply(original_cols, function(col) colData(x)[[col]])
            names(original_values) <- original_cols
            
            # Get new column names
            new_cols <- colnames(value)
            
            # Find added and modified columns
            added_cols <- setdiff(new_cols, original_cols)
            existing_cols <- intersect(new_cols, original_cols)
            
            # Check for modifications in existing columns
            modified_cols <- character(0)
            for (col in existing_cols) {
              if (!identical(value[[col]], original_values[[col]])) {
                modified_cols <- c(modified_cols, col)
              }
            }
            
            # Generate log messages
            timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
            log_messages <- character(0)
            
            # Log added columns (all in one message, capitalized, plural, colon)
            if (length(added_cols) > 0) {
              msg <- paste0(
                "[", timestamp, "] ",
                "colData<-: added ", length(added_cols), " new column(s): ",
                paste(added_cols, collapse = ", ")
              )
              log_messages <- c(log_messages, msg)
            }
            
            # Log modified columns (one per column)
            if (length(modified_cols) > 0) {
              for (col in modified_cols) {
                msg <- paste0(
                  "[", timestamp, "] ",
                  "colData<-: modified column '", col, "'"
                )
                log_messages <- c(log_messages, msg)
              }
            }
            
            # Update the object
            x@colData <- value
            
            # Update log history if there were changes
            if (length(log_messages) > 0) {
              x@log_history <- c(x@log_history, log_messages)
            }
            
            return(x)
          })