.logged_subset <- function(x, i, j, ...) {
            # Get dimensions before subsetting
            pre_dim <- dim(x)
            
            # Apply the subsetting
            result <- callNextMethod(x, i, j, ...)
            
            # If result is not a ExperimentLogged, return as is
            if (!inherits(result, "ExperimentLogged")) {
              return(result)
            }
            
            # Get dimensions after subsetting
            post_dim <- dim(result)
            
            # Generate log message if dimensions changed
            timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
            msgs <- list()
            
            # Check if rows (genes) changed
            if (pre_dim[1] != post_dim[1]) {
              genes_removed <- pre_dim[1] - post_dim[1]
              percent_removed <- round(genes_removed / pre_dim[1] * 100)
              msgs <- c(msgs, list(Time = timestamp, Operation = "subset", 
              Message = paste0(
                "removed ", genes_removed, " genes (", percent_removed, "%), ",
                post_dim[1], " genes remaining"
              ))) 
            }
            
            # Check if columns (samples) changed
            if (pre_dim[2] != post_dim[2]) {
              samples_removed <- pre_dim[2] - post_dim[2]
              percent_removed <- round(samples_removed / pre_dim[2] * 100)
              msgs <- c(msgs, list(Time = timestamp, Operation = "subset", 
              Message = paste0(
                "removed ", samples_removed, " samples (", percent_removed, "%), ",
                post_dim[2], " samples remaining"
              )))
            }
            
            # Add the messages to log history if any
            if (length(msgs) > 0) {
              result@log_history <- dplyr::bind_rows(x@log_history, dplyr::bind_rows(msgs))
            } else {
              # Preserve existing log history
              result@log_history <- x@log_history
            }
            
            return(result)
}

# `[`, `$<-` and `assays<-` use callNextMethod(), which has no parent to call
# from a class union, so they are registered once per concrete class.
#' Subset a ExperimentLogged object
#'
#' @rdname subset
#' @param x A ExperimentLogged object
#' @param i,j,... Indices for subsetting
#' @export
setMethod("[", signature = signature(x = "SummarizedExperimentLogged"), .logged_subset)

#' @rdname subset
#' @export
setMethod("[", signature = signature(x = "SingleCellExperimentLogged"), .logged_subset)

.logged_dollar_set <- function(x, name, value) {
            # Check if column exists
            is_new_column <- !(name %in% colnames(colData(x)))

            # Check if new assay is being added
            is_new_assay <- !(name %in% names(assays(x)))
            
            # Apply the modification using parent class method
            result <- callNextMethod(x, name, value)
            
            # Generate log message
            timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
            if (is_new_column) {
              msg <- list(Time = timestamp, Operation = "colData<-", 
              Message = paste0(
                "added new column '", name, "'"
              ))
            }else if(is_new_assay) {
              msg <- list(Time = timestamp, Operation = "assays<-", 
              Message = paste0(
                "added new assay '", name, "'"
              ))
            }else {
              msg <- list(Time = timestamp, Operation = "colData<-", 
              Message = paste0(
                "modified column '", name, "'"
              ))
            }
            
            # Add the message to log history
            result@log_history <- dplyr::bind_rows(x@log_history, dplyr::bind_rows(msgs))
            return(result)
}

#' Assign column to colData using `$<-` for ExperimentLogged
#' @rdname dollar-set
#' @importFrom SummarizedExperiment colData colData<-
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
setMethod("$<-", signature = signature(x = "SummarizedExperimentLogged"), .logged_dollar_set)

#' @rdname dollar-set
#' @export
setMethod("$<-", signature = signature(x = "SingleCellExperimentLogged"), .logged_dollar_set)

# Helper for colData<- logging and update
.colData_logged_update <- function(x, value) {
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
    msg <- list(Time = timestamp, Operation = "colData<-", 
    Message = paste0(
      "added ", length(added_cols), " new column(s): ",
      paste(added_cols, collapse = ", ")
    )) 
    log_messages <- c(log_messages, msg)
  }

  # Log modified columns (one per column)
  if (length(modified_cols) > 0) {
    for (col in modified_cols) {
      msg <- list(Time = timestamp, Operation = "colData<-", Message = paste0(
        "modified column '", col, "'"
      ))
      log_messages <- c(log_messages, msg)
    }
  }

  # Update the object
  x@colData <- value

  # Update log history if there were changes
  if (length(log_messages) > 0) {
    x@log_history <- dplyr::bind_rows(x@log_history, dplyr::bind_rows(log_messages))
  }

  return(x)
}



#####################################
####################################
####################################

# Helper for rowData<- logging and update
.rowData_logged_update <- function(x, value) {
  # Get original column names and values
  original_cols <- colnames(rowData(x))
  original_values <- lapply(original_cols, function(col) rowData(x)[[col]])
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
    msg <- list(Time = timestamp, Operation = "rowData<-", 
    Message = paste0(
      "added ", length(added_cols), " new column(s): ",
      paste(added_cols, collapse = ", ")
    )) 
    log_messages <- c(log_messages, msg)
  }

  # Log modified columns (one per column)
  if (length(modified_cols) > 0) {
    for (col in modified_cols) {
      msg <- list(Time = timestamp, Operation = "rowData<-", Message = paste0(
        "modified column '", col, "'"
      ))
      log_messages <- c(log_messages, msg)
    }
  }

  # Update the object. rowData is not a slot (it lives in elementMetadata or
  # mcols(rowRanges)), so let the parent class's rowData<- store it.
  plain <- .unlog(x)
  rowData(plain) <- value
  x <- .relog(plain, x)

  # Update log history if there were changes
  if (length(log_messages) > 0) {
    x@log_history <- dplyr::bind_rows(x@log_history, dplyr::bind_rows(log_messages))
  }

  return(x)
}

#' Assign column to rowData using `rowData<-` for ExperimentLogged
#' @rdname rowData
#' @export
setMethod("rowData<-", signature = signature(x = "ExperimentLogged", value = "DataFrame"),
  function(x, value) {
    .rowData_logged_update(x, value)
  })

#' @rdname rowData
#' @export
setMethod("rowData<-", signature = signature(x = "ExperimentLogged", value = "DFrame"),
  function(x, value) {
    .rowData_logged_update(x, value)
  })

######################################
#######################################
#######################################

# Helper for assays<- logging and update
.assays_logged_update <- function(x, value, result) {
  # Get original assay names and values
  original_assays <- names(assays(x))
  original_values <- assays(x)

  # Get new assay names
  new_assays <- names(value)

  # Find added and modified assays
  added_assays <- setdiff(new_assays, original_assays)
  existing_assays <- intersect(new_assays, original_assays)

  # Check for modifications in existing assays
  modified_assays <- character(0)
  for (assay in existing_assays) {
    if (!identical(value[[assay]], original_values[[assay]])) {
      modified_assays <- c(modified_assays, assay)
    }
  }

  # Generate log messages
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_messages <- character(0)

  # Log added assays (all in one message, capitalized, plural, colon)
  if (length(added_assays) > 0) {
    msg <- list(Time = timestamp, Operation = "assays<-",
    Message = paste0(
      "added ", length(added_assays), " new assay(s): ",
      paste(added_assays, collapse = ", ")
    ))
    log_messages <- c(log_messages, msg)
  }

  # Log modified assays (one per assay)
  if (length(modified_assays) > 0) {
    for (assay in modified_assays) {
      msg <- list(Time = timestamp, Operation = "assays<-", Message = paste0(
        "modified assay '", assay, "'"
      ))
      log_messages <- c(log_messages, msg)
    }
  }

  # Update log history if there were changes
  if (length(log_messages) > 0) {
    result@log_history <- dplyr::bind_rows(x@log_history, dplyr::bind_rows(log_messages))
  } else {
    result@log_history <- x@log_history
  }

  return(result)
}

#' Assign column to colData using `colData<-` for ExperimentLogged
#' @rdname colData
#' @export
setMethod("colData<-", signature = signature(x = "ExperimentLogged", value = "DataFrame"),
  function(x, value) {
    .colData_logged_update(x, value)
  })

#' @rdname colData
#' @export
setMethod("colData<-", signature = signature(x = "ExperimentLogged", value = "DFrame"),
  function(x, value) {
    .colData_logged_update(x, value)
  })

#' Assign List to assays using `assays<-` for ExperimentLogged
#' @rdname assays
#' @export
setMethod("assays<-", signature = signature(x = "SummarizedExperimentLogged", value = "SimpleList"),
  function(x, withDimnames = TRUE, ..., value) {
    result <- callNextMethod(x, withDimnames = withDimnames, ..., value = value)
    .assays_logged_update(x, value, result)
  })

#' @rdname assays
#' @export
setMethod("assays<-", signature = signature(x = "SingleCellExperimentLogged", value = "SimpleList"),
  function(x, withDimnames = TRUE, ..., value) {
    result <- callNextMethod(x, withDimnames = withDimnames, ..., value = value)
    .assays_logged_update(x, value, result)
  })