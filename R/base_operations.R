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