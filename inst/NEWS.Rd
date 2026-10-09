\name{NEWS}
\title{News for Package \pkg{omicslog}}

\section{Changes in version 0.99.0}{
  \subsection{NEW FEATURES}{
    \itemize{
      \item Initial Bioconductor submission.
      \item \code{log_start()} wraps a \code{SummarizedExperiment} or
        \code{SingleCellExperiment} object in a logged class
        (\code{SummarizedExperimentLogged} or
        \code{SingleCellExperimentLogged}) that records the operations
        applied to it.
      \item The \code{ExperimentLogged} class union groups both logged
        classes.
      \item The operation log is stored as a table with \code{Time},
        \code{Operation} and \code{Message} columns, and is shown when
        the object is printed.
      \item Logging of tidy operations through \code{dplyr} and
        \code{tidyr}: \code{filter()}, \code{mutate()}, \code{select()},
        \code{slice()} and \code{extract()}. These rely on
        \pkg{tidySummarizedExperiment} and
        \pkg{tidySingleCellExperiment}, and are registered as S3 methods
        so they work regardless of package load order.
      \item Logging of base R and Bioconductor operations: subsetting with
        \code{[}, \code{$<-}, \code{colData<-}, \code{rowData<-} and
        \code{assays<-}.
      \item Logging of \code{reducedDim<-} and \code{reducedDims<-} for
        \code{SingleCellExperimentLogged} objects.
      \item Vignette showing tidy and base R workflows.
    }
  }
}
