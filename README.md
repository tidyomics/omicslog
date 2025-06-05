EXPERIMENTAL: Getting Started with omicslog
================

# Introduction

> **WARNING**: This package is EXPERIMENTAL and under active
> development. APIs and functionality may change without notice.

``` r
library(SummarizedExperiment)
library(tidySummarizedExperiment)
library(omicslog)
data(airway, package="airway")
```

The `omicslog` package provides logging capabilities for
`SummarizedExperiment` objects. This is particularly useful for tracking
transformations in complex analysis workflows.

## Pipeline Workflow

Alternatively, you can chain these operations into a single pipeline:

``` r
# Complete workflow in a single pipeline
result <- 
  airway |>
  log_start() |>
  filter(dex == "untrt") |>
  mutate(dex_upper = toupper(dex)) |>
  mutate(Run = tolower(Run)) |> 
  filter(.feature == "ENSG00000000003")

# View the object with its complete log history
result
#> class: SummarizedExperimentLogged 
#> dim: 1 4 
#> metadata(1): ''
#> assays(1): counts
#> rownames(1): ENSG00000000003
#> rowData names(10): gene_id gene_name ... seq_coord_system symbol
#> colnames(4): SRR1039508 SRR1039512 SRR1039516 SRR1039520
#> colData names(10): SampleName cell ... BioSample dex_upper
#> 
#> Operation log:
#> [2025-06-05 10:57:58] filter: removed 4 samples (50%), 4 samples remaining
#> [2025-06-05 10:57:59] mutate: added 1 new column(s): dex_upper
#> [2025-06-05 10:58:00] mutate: modified column(s): Run
#> [2025-06-05 10:58:00] filter: removed 63676 genes (100%), 1 genes remaining
```

## Base R Pipeline

Here’s the same workflow implemented using base R operations:

``` r
# revert printing to Bioconductor style
options(restore_SummarizedExperiment_show = TRUE)

# Start with logging
result_base <- log_start(airway)

# Filter samples by dex
result_base <- result_base[, colData(result_base)$dex == "untrt"]

# Add new column with uppercase dex
colData(result_base)$dex_upper <- toupper(colData(result_base)$dex)

# Modify Run column to lowercase
colData(result_base)$Run <- tolower(colData(result_base)$Run)

# Filter features
result_base <- result_base[rownames(result_base) == "ENSG00000000003", ]

# View the object with its complete log history
result_base
#> class: SummarizedExperimentLogged 
#> dim: 1 4 
#> metadata(1): ''
#> assays(1): counts
#> rownames(1): ENSG00000000003
#> rowData names(10): gene_id gene_name ... seq_coord_system symbol
#> colnames(4): SRR1039508 SRR1039512 SRR1039516 SRR1039520
#> colData names(10): SampleName cell ... BioSample dex_upper
#> 
#> Operation log:
#> [2025-06-05 10:58:00] subset: removed 4 samples (50%), 4 samples remaining
#> [2025-06-05 10:58:00] colData<-: added 1 new column(s): dex_upper
#> [2025-06-05 10:58:00] colData<-: modified column 'Run'
#> [2025-06-05 10:58:00] subset: removed 63676 genes (100%), 1 genes remaining
```

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
#> time zone: Australia/Adelaide
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
#> [8] base     
#> 
#> other attached packages:
#>  [1] omicslog_0.99.0                 ggplot2_3.5.2                  
#>  [3] tidyr_1.3.1                     dplyr_1.1.4                    
#>  [5] tidySummarizedExperiment_1.18.1 ttservice_0.4.1                
#>  [7] SummarizedExperiment_1.38.1     Biobase_2.68.0                 
#>  [9] GenomicRanges_1.60.0            GenomeInfoDb_1.44.0            
#> [11] IRanges_2.42.0                  S4Vectors_0.46.0               
#> [13] BiocGenerics_0.54.0             generics_0.1.4                 
#> [15] MatrixGenerics_1.20.0           matrixStats_1.5.0              
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6            xfun_0.52               bslib_0.9.0            
#>  [4] htmlwidgets_1.6.4       lattice_0.22-7          vctrs_0.6.5            
#>  [7] tools_4.5.0             tibble_3.2.1            fansi_1.0.6            
#> [10] pkgconfig_2.0.3         Matrix_1.7-3            data.table_1.17.4      
#> [13] RColorBrewer_1.1-3      lifecycle_1.0.4         GenomeInfoDbData_1.2.14
#> [16] compiler_4.5.0          farver_2.1.2            stringr_1.5.1          
#> [19] htmltools_0.5.8.1       sass_0.4.10             yaml_2.3.10            
#> [22] lazyeval_0.2.2          plotly_4.10.4           pillar_1.10.2          
#> [25] crayon_1.5.3            jquerylib_0.1.4         ellipsis_0.3.2         
#> [28] DelayedArray_0.34.1     cachem_1.1.0            abind_1.4-8            
#> [31] tidyselect_1.2.1        digest_0.6.37           stringi_1.8.7          
#> [34] purrr_1.0.4             rprojroot_2.0.4         fastmap_1.2.0          
#> [37] grid_4.5.0              cli_3.6.5               SparseArray_1.8.0      
#> [40] magrittr_2.0.3          S4Arrays_1.8.1          utf8_1.2.5             
#> [43] withr_3.0.2             scales_1.4.0            UCSC.utils_1.4.0       
#> [46] rmarkdown_2.29          XVector_0.48.0          httr_1.4.7             
#> [49] evaluate_1.0.3          knitr_1.50              viridisLite_0.4.2      
#> [52] rlang_1.1.6             glue_1.8.0              rstudioapi_0.17.1      
#> [55] jsonlite_2.0.0          R6_2.6.1
```
