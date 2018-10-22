



This report was automatically generated with the R package **knitr**
(version 1.20).


```r
# knitr::stitch_rmd(script="./utility/reproduce.R", output="./stitched-output/utility/reproduce.md")
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
```


```r
library("magrittr")
requireNamespace("purrr")
# requireNamespace("checkmate")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")
```

```r
# config        <- config::get(file="data-public/metadata/config.yml")

ds_rail  <- tibble::tribble(
  ~fx               , ~path,
  "run_file_r"      , "./manipulation/te-ellis.R",
  "run_file_r"      , "./manipulation/car-ellis.R",
  "run_file_r"      , "./manipulation/randomization-block-simple.R"

  # "run_ferry_sql"   , "./manipulation/inserts-to-normalized-tables.sql"
)

run_file_r <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  base::source(minion, local=new.env())
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_ferry_sql <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  OuhscMunge::execute_sql_file(minion, config$dsn_staging)
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}

(file_found <- purrr::map_lgl(ds_rail$path, file.exists))
```

```
## [1] TRUE TRUE TRUE
```

```r
if( !all(file_found) ) {
  warning("--Missing files-- \n", paste0(ds_rail$path[!file_found], collapse="\n"))
  stop("All source files to be run should exist.")
}
```



```r
message("Starting update of files at ", Sys.time(), ".")
```

```
## Starting update of files at 2018-10-22 08:55:21.
```

```r
elapsed_time <- system.time({
  purrr::invoke_map_lgl(
    ds_rail$fx,
    ds_rail$path
  )
})
```

```
## 
## Starting `te-ellis.R` at 2018-10-22 08:55:21.
```

```
## , "home_county"            = "`HOME_COUNTY`"
##  , "fte"                    = "`FTE`"
##  , "period"                 = "`PERIOD`"
##  , "employeeid"             = "`EMPLOYEEID`"
##  , "regionid"               = "`REGIONID`"
##  , "name"                   = "`Name`"
```

```
## Warning: Closing open result set, pending rows

## Warning: Closing open result set, pending rows

## Warning: Closing open result set, pending rows
```

```
## Completed `te-ellis.R`.
```

```
## 
## Starting `car-ellis.R` at 2018-10-22 08:55:22.
```

```
## Parsed with column specification:
## cols(
##   model = col_character(),
##   mpg = col_double(),
##   cyl = col_double(),
##   disp = col_double(),
##   hp = col_double(),
##   drat = col_double(),
##   wt = col_double(),
##   qsec = col_double(),
##   vs = col_double(),
##   am = col_double(),
##   gear = col_double(),
##   carb = col_double()
## )
```

```
## Completed `car-ellis.R`.
```

```
## 
## Starting `randomization-block-simple.R` at 2018-10-22 08:55:22.
```

```
## Completed `randomization-block-simple.R`.
```

```r
message("Completed update of files at ", Sys.time(), "")
```

```
## Completed update of files at 2018-10-22 08:55:22
```

```r
elapsed_time
```

```
##    user  system elapsed 
##   0.818   0.069   0.896
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.5.1 (2018-07-02)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 18.04.1 LTS
## 
## Matrix products: default
## BLAS: /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] ggplot2_3.0.0  DBI_1.0.0      bindrcpp_0.2.2 magrittr_1.5  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.19                lattice_0.20-35            
##  [3] tidyr_0.8.1                 prettyunits_1.0.2          
##  [5] ps_1.2.0                    zoo_1.8-4                  
##  [7] assertthat_0.2.0            rprojroot_1.3-2            
##  [9] digest_0.6.18               packrat_0.4.9-3            
## [11] utf8_1.1.4                  R6_2.3.0                   
## [13] plyr_1.8.4                  backports_1.1.2            
## [15] RSQLite_2.1.1               evaluate_0.12              
## [17] highr_0.7                   pillar_1.3.0               
## [19] rlang_0.2.2                 lazyeval_0.2.1             
## [21] callr_3.0.0                 blob_1.1.1                 
## [23] checkmate_1.8.9-9000        rmarkdown_1.10             
## [25] config_0.3                  desc_1.2.0                 
## [27] labeling_0.3                devtools_2.0.0             
## [29] readr_1.2.0                 stringr_1.3.1              
## [31] bit_1.1-14                  munsell_0.5.0              
## [33] compiler_3.5.1              pkgconfig_2.0.2            
## [35] base64enc_0.1-3             pkgbuild_1.0.2             
## [37] htmltools_0.3.6             tidyselect_0.2.5           
## [39] tibble_1.4.2                viridisLite_0.3.0          
## [41] fansi_0.4.0                 crayon_1.3.4               
## [43] dplyr_0.7.7                 withr_2.1.2                
## [45] grid_3.5.1                  gtable_0.2.0               
## [47] scales_1.0.0                TabularManifest_0.1-16.9003
## [49] cli_1.0.1                   stringi_1.2.4              
## [51] fs_1.2.6                    remotes_2.0.0              
## [53] testit_0.8                  testthat_2.0.1             
## [55] tools_3.5.1                 bit64_0.9-7                
## [57] OuhscMunge_0.1.9.9009       glue_1.3.0                 
## [59] markdown_0.8                purrr_0.2.5                
## [61] hms_0.4.2.9001              rsconnect_0.8.8            
## [63] processx_3.2.0              pkgload_1.0.1              
## [65] yaml_2.2.0                  colorspace_1.3-2           
## [67] sessioninfo_1.1.0           memoise_1.1.0              
## [69] knitr_1.20                  bindr_0.1.1                
## [71] usethis_1.4.0
```

```r
Sys.time()
```

```
## [1] "2018-10-22 08:55:22 CDT"
```

