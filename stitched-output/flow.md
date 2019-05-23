



This report was automatically generated with the R package **knitr**
(version 1.23).


```r
# knitr::stitch_rmd(script="flow.R", output="stitched-output/flow.md")
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
```


```r
library("magrittr")
requireNamespace("purrr")
# requireNamespace("checkmate")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")
```

```r
# config        <- config::get()

# Allow multiple files below to have the same chunk name.
#    If the `root.dir` option is properly managed in the Rmd files, no files will be overwritten.
options(knitr.duplicate.label = "allow")

ds_rail  <- tibble::tribble(
  ~fx               , ~path,

  # Simulate observed data
  "run_file_r"      , "manipulation/simulation/simulate-mlm-1.R",
  # "run_file_r"      , "manipulation/simulation/simulate-te.R",

  # First run the manipulation files to prepare the dataset(s).
  "run_file_r"      , "manipulation/car-ellis.R",
  "run_file_r"      , "manipulation/mlm-1-ellis.R",
  "run_file_r"      , "manipulation/te-ellis.R",
  "run_file_r"      , "manipulation/subject-1-ellis.R",

  # "run_ferry_sql" , "manipulation/inserts-to-normalized-tables.sql"
  "run_file_r"      , "manipulation/randomization-block-simple.R",

  # Scribes
  "run_file_r"    , "manipulation/mlm-1-scribe.R",
  "run_file_r"    , "manipulation/te-scribe.R",

  # Reports
  "run_rmd"       , "analysis/car-report-1/car-report-1.Rmd",
  "run_rmd"       , "analysis/report-te-1/report-te-1.Rmd"

  # Dashboards
  #"run_rmd"       , "analysis/dashboard-1/dashboard-1.Rmd"
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
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
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
## Starting update of files at 2019-05-23 14:23:59.
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
## Starting `simulate-mlm-1.R` at 2019-05-23 14:23:59.
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
## Registered S3 methods overwritten by 'ggplot2':
##   method         from 
##   [.quosures     rlang
##   c.quosures     rlang
##   print.quosures rlang
```

```
## Completed `simulate-mlm-1.R`.
```

```
## 
## Starting `car-ellis.R` at 2019-05-23 14:24:01.
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
## Starting `mlm-1-ellis.R` at 2019-05-23 14:24:01.
```

```
## Completed `mlm-1-ellis.R`.
```

```
## 
## Starting `te-ellis.R` at 2019-05-23 14:24:01.
```

```
## Completed `te-ellis.R`.
```

```
## 
## Starting `subject-1-ellis.R` at 2019-05-23 14:24:02.
```

```
## Completed `subject-1-ellis.R`.
```

```
## 
## Starting `randomization-block-simple.R` at 2019-05-23 14:24:02.
```

```
## Completed `randomization-block-simple.R`.
```

```
## 
## Starting `mlm-1-scribe.R` at 2019-05-23 14:24:02.
```

```
## Loading required namespace: RcppRoll
```

```
## Unique subjects    : 20
## Unique waves       : 10
## Unique counties    : 3
## Year range         : 2000 2014
```

```
## Completed `mlm-1-scribe.R`.
```

```
## 
## Starting `te-scribe.R` at 2019-05-23 14:24:02.
```

```
## Unique counties    : 77
## Unique months      : 40
## Month range        : 2012-06-15  2015-09-15
```

```
## Completed `te-scribe.R`.
```

```
## 
## Starting `car-report-1.Rmd` at 2019-05-23 14:24:02.
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
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS car-report-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output car-report-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.6/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/RtmpU9bHv2/rmarkdown-str3a19513bf380.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
```

```
## 
## Output created: car-report-1.html
```

```
## /home/wibeasley/Documents/wibeasley/RAnalysisSkeleton/analysis/car-report-1/car-report-1.html
```

```
## 
## Starting `report-te-1.Rmd` at 2019-05-23 14:24:13.
```

```
## 
## 
## processing file: report-te-1.Rmd
```

```
##   |                                                                         |                                                                 |   0%  |                                                                         |..                                                               |   3%
##    inline R code fragments
## 
##   |                                                                         |....                                                             |   6%
## label: unnamed-chunk-1-2 (with options) 
## List of 2
##  $ echo   : symbol F
##  $ message: symbol F
## 
##   |                                                                         |......                                                           |  10%
##   ordinary text without R code
## 
##   |                                                                         |........                                                         |  13%
## label: set-options (with options) 
## List of 1
##  $ echo: symbol F
## 
##   |                                                                         |..........                                                       |  16%
##   ordinary text without R code
## 
##   |                                                                         |.............                                                    |  19%
## label: load-sources (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |...............                                                  |  23%
##   ordinary text without R code
## 
##   |                                                                         |.................                                                |  26%
## label: load-packages (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
```

```
## Loading required package: Matrix
```

```
##   |                                                                         |...................                                              |  29%
##   ordinary text without R code
## 
##   |                                                                         |.....................                                            |  32%
## label: declare-globals (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |.......................                                          |  35%
##   ordinary text without R code
## 
##   |                                                                         |.........................                                        |  39%
## label: rmd-specific (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |...........................                                      |  42%
##   ordinary text without R code
## 
##   |                                                                         |.............................                                    |  45%
## label: load-data (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |...............................                                  |  48%
##   ordinary text without R code
## 
##   |                                                                         |..................................                               |  52%
## label: tweak-data (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |....................................                             |  55%
##    inline R code fragments
## 
##   |                                                                         |......................................                           |  58%
## label: marginals-county (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
```

```
##   |                                                                         |........................................                         |  61%
##   ordinary text without R code
## 
##   |                                                                         |..........................................                       |  65%
## label: marginals-county-month (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
```

```
##   |                                                                         |............................................                     |  68%
##   ordinary text without R code
## 
##   |                                                                         |..............................................                   |  71%
## label: scatterplots (with options) 
## List of 4
##  $ echo      : symbol echo_chunks
##  $ message   : symbol message_chunks
##  $ fig.width : num 9
##  $ fig.height: num 6
```

```
##   |                                                                         |................................................                 |  74%
##   ordinary text without R code
## 
##   |                                                                         |..................................................               |  77%
## label: models (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
```

```
## refitting model(s) with ML (instead of REML)
```

```
##   |                                                                         |....................................................             |  81%
##   ordinary text without R code
## 
##   |                                                                         |.......................................................          |  84%
## label: model-results-table (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
##  $ warning: logi TRUE
## 
##   |                                                                         |.........................................................        |  87%
##    inline R code fragments
## 
##   |                                                                         |...........................................................      |  90%
## label: session-info-3 (with options) 
## List of 1
##  $ echo: logi FALSE
## 
##   |                                                                         |.............................................................    |  94%
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
## output file: report-te-1.knit.md
```

```
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS report-te-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output report-te-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.6/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/RtmpU9bHv2/rmarkdown-str3a1916197576.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
```

```
## 
## Output created: report-te-1.html
```

```
## /home/wibeasley/Documents/wibeasley/RAnalysisSkeleton/analysis/report-te-1/report-te-1.html
```

```r
message("Completed update of files at ", Sys.time(), "")
```

```
## Completed update of files at 2019-05-23 14:24:32
```

```r
elapsed_time
```

```
##    user  system elapsed 
##  24.043   2.402  32.581
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.6.0 (2019-04-26)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 18.04.2 LTS
## 
## Matrix products: default
## BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
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
## [1] lme4_1.1-21   Matrix_1.2-17 knitr_1.23    ggplot2_3.1.1 magrittr_1.5 
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.1                  lubridate_1.7.4            
##  [3] lattice_0.20-38             tidyr_0.8.3                
##  [5] prettyunits_1.0.2           ps_1.3.0                   
##  [7] zoo_1.8-5                   assertthat_0.2.1           
##  [9] rprojroot_1.3-2             digest_0.6.18              
## [11] packrat_0.5.0               R6_2.4.0                   
## [13] plyr_1.8.4                  backports_1.1.4            
## [15] RSQLite_2.1.1               evaluate_0.13              
## [17] highr_0.8                   pillar_1.4.0               
## [19] rlang_0.3.4                 lazyeval_0.2.2             
## [21] minqa_1.2.4                 rstudioapi_0.10            
## [23] nloptr_1.2.1                callr_3.2.0                
## [25] blob_1.1.1                  checkmate_1.9.3            
## [27] rmarkdown_1.12              splines_3.6.0              
## [29] config_0.3                  desc_1.2.0                 
## [31] labeling_0.3                devtools_2.0.2             
## [33] readr_1.3.1                 stringr_1.4.0              
## [35] bit_1.1-14                  munsell_0.5.0              
## [37] compiler_3.6.0              xfun_0.7                   
## [39] pkgconfig_2.0.2             pkgbuild_1.0.3             
## [41] htmltools_0.3.6             tidyselect_0.2.5           
## [43] tibble_2.1.1                RcppRoll_0.3.0             
## [45] viridisLite_0.3.0           crayon_1.3.4               
## [47] dplyr_0.8.1                 withr_2.1.2                
## [49] MASS_7.3-51.4               grid_3.6.0                 
## [51] nlme_3.1-140                gtable_0.3.0               
## [53] DBI_1.0.0                   scales_1.0.0               
## [55] TabularManifest_0.1-16.9003 cli_1.1.0                  
## [57] stringi_1.4.3               fs_1.3.1                   
## [59] remotes_2.0.4               testit_0.9                 
## [61] testthat_2.1.1              boot_1.3-22                
## [63] tools_3.6.0                 bit64_0.9-7                
## [65] OuhscMunge_0.1.9.9010       glue_1.3.1                 
## [67] purrr_0.3.2                 hms_0.4.2                  
## [69] processx_3.3.1              pkgload_1.0.2              
## [71] yaml_2.2.0                  colorspace_1.4-1           
## [73] sessioninfo_1.1.1           memoise_1.1.0              
## [75] usethis_1.5.0
```

```r
Sys.time()
```

```
## [1] "2019-05-23 14:24:32 CDT"
```

