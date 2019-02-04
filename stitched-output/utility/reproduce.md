



This report was automatically generated with the R package **knitr**
(version 1.21).


```r
# knitr::stitch_rmd(script="./utility/reproduce.R", output="./stitched-output/utility/reproduce.md")
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
```


```r
library("magrittr")
requireNamespace("purrr")
```

```
## Loading required namespace: purrr
```

```r
# requireNamespace("checkmate")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")
```

```
## Loading required namespace: OuhscMunge
```

```r
# config        <- config::get(file="data-public/metadata/config.yml")

# Allow multiple files below to have the same chunk name.
#    If the `root.dir` option is properly managed in the Rmd files, no files will be overwritten.
options(knitr.duplicate.label = "allow")

ds_rail  <- tibble::tribble(
  ~fx               , ~path,

  # Simulate observed data
  "run_file_r"      , "manipulation/simulation/simulate-mlm-1.R",

  # First run the manipulation files to prepare the dataset(s).
  "run_file_r"      , "manipulation/te-ellis.R",
  "run_file_r"      , "manipulation/car-ellis.R",

  # "run_ferry_sql" , "manipulation/inserts-to-normalized-tables.sql"
  "run_file_r"      , "manipulation/randomization-block-simple.R",

  # Next render the analysis report(s):
  "run_rmd"       , "analysis/car-report-1/car-report-1.Rmd"
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
run_rmd <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  path_out <- rmarkdown::render(minion, envir=new.env())
  Sys.sleep(3) # Sleep for three secs, to let pandoc finish
  message(path_out)
  return( TRUE )
}

(file_found <- purrr::map_lgl(ds_rail$path, file.exists))
```

```
## [1] TRUE TRUE TRUE TRUE TRUE
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
## Starting update of files at 2019-02-04 00:28:46.
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
## Starting `simulate-mlm-1.R` at 2019-02-04 00:28:46.
```

```
## Loading required namespace: readr
```

```
## Loading required namespace: tidyr
```

```
## Loading required namespace: dplyr
```

```
## Loading required namespace: testit
```

```
## Loading required namespace: checkmate
```

```
## Loading required namespace: DBI
```

```
## Loading required namespace: RSQLite
```

```
## Completed `simulate-mlm-1.R`.
```

```
## 
## Starting `te-ellis.R` at 2019-02-04 00:28:48.
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
## Completed `te-ellis.R`.
```

```
## 
## Starting `car-ellis.R` at 2019-02-04 00:28:49.
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
## Starting `randomization-block-simple.R` at 2019-02-04 00:28:49.
```

```
## Completed `randomization-block-simple.R`.
```

```
## 
## Starting `car-report-1.Rmd` at 2019-02-04 00:28:49.
```

```
## 
## 
## processing file: car-report-1.Rmd
```

```
##   |                                                                         |                                                                 |   0%  |                                                                         |..                                                               |   3%
##    inline R code fragments
## 
##   |                                                                         |....                                                             |   7%
## label: unnamed-chunk-2 (with options) 
## List of 2
##  $ echo   : symbol F
##  $ message: symbol F
## 
##   |                                                                         |.......                                                          |  10%
##   ordinary text without R code
## 
##   |                                                                         |.........                                                        |  14%
## label: set-options (with options) 
## List of 1
##  $ echo: symbol F
## 
##   |                                                                         |...........                                                      |  17%
##   ordinary text without R code
## 
##   |                                                                         |.............                                                    |  21%
## label: load-sources (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |................                                                 |  24%
##   ordinary text without R code
## 
##   |                                                                         |..................                                               |  28%
## label: load-packages (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |....................                                             |  31%
##   ordinary text without R code
## 
##   |                                                                         |......................                                           |  34%
## label: declare-globals (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |.........................                                        |  38%
##   ordinary text without R code
## 
##   |                                                                         |...........................                                      |  41%
## label: rmd-specific (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |.............................                                    |  45%
##   ordinary text without R code
## 
##   |                                                                         |...............................                                  |  48%
## label: load-data (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |..................................                               |  52%
##   ordinary text without R code
## 
##   |                                                                         |....................................                             |  55%
## label: tweak-data (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |......................................                           |  59%
##    inline R code fragments
## 
##   |                                                                         |........................................                         |  62%
## label: marginals (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
```

```
##   |                                                                         |...........................................                      |  66%
##   ordinary text without R code
## 
##   |                                                                         |.............................................                    |  69%
## label: scatterplots (with options) 
## List of 3
##  $ echo     : symbol echo_chunks
##  $ message  : symbol message_chunks
##  $ fig.width: num 7
```

```
##   |                                                                         |...............................................                  |  72%
##   ordinary text without R code
## 
##   |                                                                         |.................................................                |  76%
## label: models (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |....................................................             |  79%
##   ordinary text without R code
## 
##   |                                                                         |......................................................           |  83%
## label: model-results-table (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
##  $ warning: logi TRUE
## 
##   |                                                                         |........................................................         |  86%
##    inline R code fragments
## 
##   |                                                                         |..........................................................       |  90%
## label: session-info-3 (with options) 
## List of 1
##  $ echo: logi FALSE
## 
##   |                                                                         |.............................................................    |  93%
##   ordinary text without R code
## 
##   |                                                                         |...............................................................  |  97%
## label: session-duration (with options) 
## List of 1
##  $ echo: logi FALSE
## 
##   |                                                                         |.................................................................| 100%
##    inline R code fragments
```

```
## output file: car-report-1.knit.md
```

```
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS car-report-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output car-report-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.5/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/RtmprOWzL5/rmarkdown-str730276e3d560.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
```

```
## 
## Output created: car-report-1.html
```

```
## /home/wibeasley/Documents/wibeasley/RAnalysisSkeleton/analysis/car-report-1/car-report-1.html
```

```r
message("Completed update of files at ", Sys.time(), "")
```

```
## Completed update of files at 2019-02-04 00:28:59
```

```r
elapsed_time
```

```
##    user  system elapsed 
##   9.034   0.907  12.821
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.5.2 (2018-12-20)
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
## [1] knitr_1.21     ggplot2_3.1.0  bindrcpp_0.2.2 magrittr_1.5  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.0            lubridate_1.7.4       lattice_0.20-38      
##  [4] tidyr_0.8.2           prettyunits_1.0.2     ps_1.3.0             
##  [7] zoo_1.8-4             assertthat_0.2.0      rprojroot_1.3-2      
## [10] digest_0.6.18         packrat_0.5.0         R6_2.3.0             
## [13] plyr_1.8.4            backports_1.1.3       RSQLite_2.1.1        
## [16] evaluate_0.12         highr_0.7             pillar_1.3.1         
## [19] rlang_0.3.1           lazyeval_0.2.1        callr_3.1.1          
## [22] blob_1.1.1            checkmate_1.9.1       rmarkdown_1.11       
## [25] config_0.3            desc_1.2.0            labeling_0.3         
## [28] devtools_2.0.1        readr_1.3.1           stringr_1.3.1        
## [31] bit_1.1-14            munsell_0.5.0         compiler_3.5.2       
## [34] xfun_0.4              pkgconfig_2.0.2       pkgbuild_1.0.2       
## [37] htmltools_0.3.6       tidyselect_0.2.5      tibble_2.0.1         
## [40] viridisLite_0.3.0     crayon_1.3.4          dplyr_0.7.8          
## [43] withr_2.1.2           grid_3.5.2            gtable_0.2.0         
## [46] DBI_1.0.0             scales_1.0.0.9000     cli_1.0.1            
## [49] stringi_1.2.4         fs_1.2.6              remotes_2.0.2        
## [52] testit_0.9            testthat_2.0.1        tools_3.5.2          
## [55] bit64_0.9-7           OuhscMunge_0.1.9.9009 glue_1.3.0           
## [58] purrr_0.3.0           hms_0.4.2.9001        processx_3.2.1       
## [61] pkgload_1.0.2         yaml_2.2.0            colorspace_1.4-0     
## [64] sessioninfo_1.1.1     memoise_1.1.0         bindr_0.1.1          
## [67] usethis_1.4.0
```

```r
Sys.time()
```

```
## [1] "2019-02-04 00:28:59 CST"
```

