Getting Started with omiclog
================
true

# Introduction

``` r
library(omiclog)
library(SummarizedExperiment)
library(tidySummarizedExperiment)
```

The `omiclog` package provides logging capabilities for
`SummarizedExperiment` objects. This is particularly useful for tracking
transformations in complex analysis workflows.

# Basic Usage

## Creating a Logged SummarizedExperiment

To start logging, simply apply the `log()` function to any
`SummarizedExperiment` object:

``` r
# Load example dataset
data <- tidySummarizedExperiment::pasilla

# Start logging
logged_data <- log(data)
```

## Step-by-Step Workflow

You can perform operations step by step, examining the log at each
stage:

``` r
# Filter to keep only treated samples
treated <- logged_data |>
  filter(condition == "treated")

# Add a log-transformed counts column
transformed <- treated |>
  mutate(log_counts = log2(counts + 1))

# Filter to a specific gene
gene_of_interest <- transformed |>
  filter(.feature == "FBgn0000003")

# View the final object with its log
gene_of_interest
#> # A SummarizedExperiment-tibble abstraction: 3 × 6
#> # Features=1 | Samples=3 | Assays=counts, log_counts
#>   .feature    .sample counts log_counts condition type      
#>   <chr>       <chr>    <int>      <dbl> <chr>     <chr>     
#> 1 FBgn0000003 trt1         0          0 treated   single_end
#> 2 FBgn0000003 trt2         0          0 treated   paired_end
#> 3 FBgn0000003 trt3         1          1 treated   paired_end
```

## Pipeline Workflow

Alternatively, you can chain these operations into a single pipeline:

``` r
# Complete workflow in a single pipeline
result <- tidySummarizedExperiment::pasilla |>
  log() |>
  filter(condition == "treated") |>
  mutate(log_counts = log2(counts + 1)) |>
  filter(.feature == "FBgn0000003")

# View the object with its complete log history
result
#> # A SummarizedExperiment-tibble abstraction: 3 × 6
#> # Features=1 | Samples=3 | Assays=counts, log_counts
#>   .feature    .sample counts log_counts condition type      
#>   <chr>       <chr>    <int>      <dbl> <chr>     <chr>     
#> 1 FBgn0000003 trt1         0          0 treated   single_end
#> 2 FBgn0000003 trt2         0          0 treated   paired_end
#> 3 FBgn0000003 trt3         1          1 treated   paired_end
```

The log automatically tracks each transformation in sequence, showing: -
How many samples were filtered when selecting only treated conditions -
Which columns were modified with the log transformation - How many
features were removed when filtering to a specific gene

# Advanced Usage

## Working with the Log History

The log history is stored in the object and can be accessed directly:

``` r
# Access the log history
log_history <- result@log_history
print(log_history)
#> character(0)
```

This allows you to programmatically work with the log if needed.

# Session Info

``` r
sessionInfo()
#> R version 4.5.0 (2025-04-11)
#> Platform: x86_64-apple-darwin20
#> Running under: macOS Sonoma 14.6.1
#> 
#> Matrix products: default
#> BLAS:   /Library/Frameworks/R.framework/Versions/4.5-x86_64/Resources/lib/libRblas.0.dylib 
#> LAPACK: /Library/Frameworks/R.framework/Versions/4.5-x86_64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> time zone: Europe/Rome
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
#> [8] base     
#> 
#> other attached packages:
#>  [1] ggplot2_3.5.2                   tidyr_1.3.1                    
#>  [3] dplyr_1.1.4                     tidySummarizedExperiment_1.18.1
#>  [5] ttservice_0.4.1                 SummarizedExperiment_1.38.1    
#>  [7] Biobase_2.68.0                  GenomicRanges_1.60.0           
#>  [9] GenomeInfoDb_1.44.0             IRanges_2.42.0                 
#> [11] S4Vectors_0.46.0                BiocGenerics_0.54.0            
#> [13] generics_0.1.4                  MatrixGenerics_1.20.0          
#> [15] matrixStats_1.5.0               omiclog_0.99.0                 
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6            xfun_0.52               bslib_0.9.0            
#>  [4] htmlwidgets_1.6.4       lattice_0.22-7          vctrs_0.6.5            
#>  [7] tools_4.5.0             tibble_3.2.1            fansi_1.0.6            
#> [10] pkgconfig_2.0.3         Matrix_1.7-3            data.table_1.17.2      
#> [13] RColorBrewer_1.1-3      lifecycle_1.0.4         GenomeInfoDbData_1.2.14
#> [16] compiler_4.5.0          farver_2.1.2            stringr_1.5.1          
#> [19] htmltools_0.5.8.1       sass_0.4.10             yaml_2.3.10            
#> [22] lazyeval_0.2.2          plotly_4.10.4           pillar_1.10.2          
#> [25] crayon_1.5.3            jquerylib_0.1.4         ellipsis_0.3.2         
#> [28] DelayedArray_0.34.1     cachem_1.1.0            abind_1.4-8            
#> [31] tidyselect_1.2.1        digest_0.6.37           stringi_1.8.7          
#> [34] purrr_1.0.4             rprojroot_2.0.4         fastmap_1.2.0          
#> [37] grid_4.5.0              cli_3.6.5               SparseArray_1.8.0      
#> [40] magrittr_2.0.3          S4Arrays_1.8.0          utf8_1.2.5             
#> [43] withr_3.0.2             UCSC.utils_1.4.0        scales_1.4.0           
#> [46] rmarkdown_2.29          XVector_0.48.0          httr_1.4.7             
#> [49] evaluate_1.0.3          knitr_1.50              viridisLite_0.4.2      
#> [52] rlang_1.1.6             glue_1.8.0              rstudioapi_0.17.1      
#> [55] jsonlite_2.0.0          R6_2.6.1
```
