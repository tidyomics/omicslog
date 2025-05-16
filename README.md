# omiclog: Logging for High-Throughput Omics Data Analysis

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Overview

The `omiclog` package provides logging capabilities for `SummarizedExperiment` objects, helping users track data transformations during analysis. It extends `SummarizedExperiment` to include operation tracking such as filtering and column modifications, displaying a log when the object is printed.

## Installation

```r
# Install from Bioconductor (once available)
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("omiclog")

# Or install the development version from GitHub
# install.packages("devtools")
devtools::install_github("yourusername/omiclog")
```

## Usage

```r
library(omiclog)
library(tidySummarizedExperiment)

# Start logging a SummarizedExperiment object
se <- tidySummarizedExperiment::pasilla |>
  log()

# Apply operations
result <- se |>
  filter(condition == "treated") |>
  mutate(log_counts = log2(counts + 1)) |>
  filter(.feature == "FBgn0000003")

# The result will include a log of all operations
print(result)
```

## Features

- Track filtering operations on genes and samples
- Log column additions and modifications
- Maintain a complete history of operations
- Display the log history when printing the object

## License

This package is licensed under the Artistic-2.0 license. 