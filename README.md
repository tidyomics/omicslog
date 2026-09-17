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
  select(!albut) |>
  mutate(dex_upper = toupper(dex)) |>
  extract(col = dex,into = "treat") |>
  mutate(Run = tolower(Run)) |> 
  filter(.feature == "ENSG00000000003") |>
  slice(3)

# View the object with the top log history as text
result
#> class: SummarizedExperimentLogged 
#> dim: 1 4 
#> metadata(3): '' latest_filter_scope_report latest_mutate_scope_report
#> assays(1): counts
#> rownames(1): ENSG00000000003
#> rowData names(10): gene_id gene_name ... seq_coord_system symbol
#> colnames(4): SRR1039508 SRR1039512 SRR1039516 SRR1039520
#> colData names(10): SampleName cell ... BioSample dex_upper
#>
#> Operation log:
#> [2026-05-19 16:28:12] filter: removed 4 sample(s) (50%), 4 sample(s) remaining
#> [2026-05-19 16:28:12] mutate: added 1 new column(s): dex_upper
#> [2026-05-19 16:28:12] mutate: modified column(s): Run
#> [2026-05-19 16:28:13] filter: removed 63676 gene(s) (100%), 1 gene(s) remaining 

# View the table with the complete log history
print(result@log_history,width=Inf)
#> # A tibble: 4 × 3
#>   Time                Operation
#>   <chr>               <chr>    
#> 1 2026-05-19 16:28:12 filter   
#> 2 2026-05-19 16:28:12 mutate   
#> 3 2026-05-19 16:28:12 mutate   
#> 4 2026-05-19 16:28:13 filter   
#>   Message                                          
#>   <chr>                                            
#> 1 removed 4 sample(s) (50%), 4 sample(s) remaining 
#> 2 added 1 new column(s): dex_upper                 
#> 3 modified column(s): Run                          
#> 4 removed 63676 gene(s) (100%), 1 gene(s) remaining
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
#> [2026-05-19 16:34:15] subset: removed 4 samples (50%), 4 samples remaining
#> [2026-05-19 16:34:15] colData<-: added 1 new column(s): dex_upper
#> [2026-05-19 16:34:15] colData<-: modified column 'Run'
#> [2026-05-19 16:34:15] subset: removed 63676 genes (100%), 1 genes remaining

# View the table with the complete log history
print(result_base@log_history,width=Inf)
#> # A tibble: 4 × 3
#>   Time                Operation Message                                      
#>   <chr>               <chr>     <chr>                                        
#> 1 2026-05-19 16:34:15 subset    removed 4 samples (50%), 4 samples remaining 
#> 2 2026-05-19 16:34:15 colData<- added 1 new column(s): dex_upper             
#> 3 2026-05-19 16:34:15 colData<- modified column 'Run'                        
#> 4 2026-05-19 16:34:15 subset    removed 63676 genes (100%), 1 genes remaining
```

# Session Info

``` r
sessionInfo()
#> R version 4.5.3 (2026-03-11)
#> Platform: x86_64-conda-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS/LAPACK: /home/juan/miniconda3/envs/r453/lib/libopenblasp-r0.3.30.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: Europe/Berlin
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
#> [8] base     
#> 
#> other attached packages:
#>  [1] omicslog_0.99.0                 ggplot2_4.0.2                  
#>  [3] tidyr_1.3.2                     dplyr_1.2.0                    
#>  [5] tidySummarizedExperiment_1.20.1 ttservice_0.5.3                
#>  [7] SummarizedExperiment_1.40.0     Biobase_2.70.0                 
#>  [9] GenomicRanges_1.62.1            Seqinfo_1.0.0                  
#> [11] IRanges_2.44.0                  S4Vectors_0.48.0               
#> [13] BiocGenerics_0.56.0             generics_0.1.4                 
#> [15] MatrixGenerics_1.22.0           matrixStats_1.5.0              
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6        xfun_0.56           htmlwidgets_1.6.4  
#>  [4] lattice_0.22-9      vctrs_0.7.1         tools_4.5.3        
#>  [7] tibble_3.3.1        pkgconfig_2.0.3     Matrix_1.7-4       
#> [10] data.table_1.17.8   RColorBrewer_1.1-3  S7_0.2.1           
#> [13] desc_1.4.3          lifecycle_1.0.5     compiler_4.5.3     
#> [16] farver_2.1.2        stringr_1.6.0       codetools_0.2-20   
#> [19] htmltools_0.5.9     lazyeval_0.2.2      plotly_4.12.0      
#> [22] pillar_1.11.1       ellipsis_0.3.2      DelayedArray_0.36.0
#> [25] abind_1.4-8         commonmark_2.0.0    tidyselect_1.2.1   
#> [28] digest_0.6.39       stringi_1.8.7       purrr_1.2.1        
#> [31] rprojroot_2.1.1     fastmap_1.2.0       grid_4.5.3         
#> [34] cli_3.6.5           SparseArray_1.10.8  magrittr_2.0.4     
#> [37] S4Arrays_1.10.1     pkgbuild_1.4.8      utf8_1.2.6         
#> [40] withr_3.0.2         scales_1.4.0        roxygen2_8.0.0     
#> [43] XVector_0.50.0      httr_1.4.8          otel_0.2.0         
#> [46] evaluate_1.0.5      knitr_1.51          viridisLite_0.4.3  
#> [49] rlang_1.1.7         glue_1.8.0          xml2_1.5.2         
#> [52] pkgload_1.5.2       jsonlite_2.0.0      R6_2.6.1
```
