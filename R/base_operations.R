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