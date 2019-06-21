



This report was automatically generated with the R package **knitr**
(version 1.23).


```r
# knitr::stitch_rmd(script="flow.R", output="stitched-output/flow.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
```


```r
library("magrittr")
requireNamespace("purrr")
# requireNamespace("checkmate")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")
```

```r
# Allow multiple files below to have the same chunk name.
#    If the `root.dir` option is properly managed in the Rmd files, no files will be overwritten.
options(knitr.duplicate.label = "allow")

config        <- config::get()

# open log
if( interactive() ) {
  sink_log <- FALSE
} else {
  message("Creating flow log file at ", config$path_log_flow)

  if( !dir.exists(dirname(config$path_log_flow)) ) {
    # Create a month-specific directory, so they're easier to find & compress later.
    dir.create(dirname(config$path_log_flow), recursive=T)
  }

  file_log  <- file(
    description   = config$path_log_flow,
    open          = "wt"
  )
  sink(
    file    = file_log,
    type    = "message"
  )
  sink_log <- TRUE
}
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
message("Starting daily update of [[project name]] at ", Sys.time(), ".")
```

```
## Starting daily update of [[project name]] at 2019-06-21 18:33:26.
```

```r
warn_level_initial <- as.integer(options("warn"))
# options(warn=0)  # warnings are stored until the top–level function returns
# options(warn=2)  # treat warnings as errors

elapsed_duration <- system.time({
  purrr::invoke_map_lgl(
    ds_rail$fx,
    ds_rail$path#,
    # ds_rail$path_output
  )
})
```

```
## 
## Starting `simulate-mlm-1.R` at 2019-06-21 18:33:26.
```

```
## Completed `simulate-mlm-1.R`.
```

```
## 
## Starting `car-ellis.R` at 2019-06-21 18:33:26.
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
## Starting `mlm-1-ellis.R` at 2019-06-21 18:33:26.
```

```
## Completed `mlm-1-ellis.R`.
```

```
## 
## Starting `te-ellis.R` at 2019-06-21 18:33:27.
```

```
## Completed `te-ellis.R`.
```

```
## 
## Starting `subject-1-ellis.R` at 2019-06-21 18:33:27.
```

```
## Completed `subject-1-ellis.R`.
```

```
## 
## Starting `randomization-block-simple.R` at 2019-06-21 18:33:27.
```

```
## Completed `randomization-block-simple.R`.
```

```
## 
## Starting `mlm-1-scribe.R` at 2019-06-21 18:33:27.
```

```
## Row Count          : 200
## Unique subjects    : 20
## Unique waves       : 10
## Unique counties    : 3
## Unique years       : 15
## Year range         : 2000 2014
```

```
## Completed `mlm-1-scribe.R`.
```

```
## 
## Starting `te-scribe.R` at 2019-06-21 18:33:27.
```

```
## Row Count          : 3,080
## Unique counties    : 77
## Unique months      : 40
## Month range        : 2012-06-15  2015-09-15
```

```
## Completed `te-scribe.R`.
```

```
## 
## Starting `car-report-1.Rmd` at 2019-06-21 18:33:27.
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
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS car-report-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output car-report-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.6/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/Rtmp2V8ZjI/rmarkdown-str58e93830ab5.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
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
## Starting `report-te-1.Rmd` at 2019-06-21 18:33:38.
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
## 
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
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS report-te-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output report-te-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.6/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/Rtmp2V8ZjI/rmarkdown-str58e94056a20f.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
```

```
## 
## Output created: report-te-1.html
```

```
## /home/wibeasley/Documents/wibeasley/RAnalysisSkeleton/analysis/report-te-1/report-te-1.html
```

```r
message("Completed daily update of [[project name]] at ", Sys.time(), "")
```

```
## Completed daily update of [[project name]] at 2019-06-21 18:33:55
```

```r
elapsed_duration
```

```
##    user  system elapsed 
##  19.574   2.712  28.272
```

```r
options(warn=warn_level_initial)  # Restore the whatever warning level you started with.
```

```r
# close(file_log)
if( sink_log ) {
  sink(file = NULL, type = "message") # ends the last diversion (of the specified type).
  message("Closing flow log file at ", gsub("/", "\\\\", config$path_log_flow))
}

# bash: Rscript flow.R
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
## [1] lme4_1.1-21   Matrix_1.2-17 knitr_1.23    ggplot2_3.2.0 magrittr_1.5 
## 
## loaded via a namespace (and not attached):
##  [1] pkgload_1.0.2               tidyr_0.8.3                
##  [3] bit64_0.9-7                 viridisLite_0.3.0          
##  [5] splines_3.6.0               OuhscMunge_0.1.9.9010      
##  [7] assertthat_0.2.1            highr_0.8                  
##  [9] blob_1.1.1                  yaml_2.2.0                 
## [11] remotes_2.0.4               sessioninfo_1.1.1          
## [13] pillar_1.4.1                RSQLite_2.1.1              
## [15] backports_1.1.4             lattice_0.20-38            
## [17] glue_1.3.1                  digest_0.6.19              
## [19] checkmate_1.9.3             testit_0.9                 
## [21] minqa_1.2.4                 colorspace_1.4-1           
## [23] htmltools_0.3.6             pkgconfig_2.0.2            
## [25] devtools_2.0.2              config_0.3                 
## [27] purrr_0.3.2                 scales_1.0.0               
## [29] processx_3.3.1              tibble_2.1.3               
## [31] usethis_1.5.0               DT_0.7                     
## [33] withr_2.1.2                 lazyeval_0.2.2             
## [35] cli_1.1.0                   crayon_1.3.4               
## [37] memoise_1.1.0               evaluate_0.14              
## [39] ps_1.3.0                    fs_1.3.1                   
## [41] TabularManifest_0.1-16.9003 nlme_3.1-140               
## [43] MASS_7.3-51.4               pkgbuild_1.0.3             
## [45] tools_3.6.0                 prettyunits_1.0.2          
## [47] hms_0.4.2                   stringr_1.4.0              
## [49] odbc_1.1.6                  munsell_0.5.0              
## [51] callr_3.2.0                 packrat_0.5.0              
## [53] compiler_3.6.0              rlang_0.3.4                
## [55] nloptr_1.2.1                grid_3.6.0                 
## [57] rstudioapi_0.10             htmlwidgets_1.3            
## [59] labeling_0.3                rmarkdown_1.13             
## [61] boot_1.3-22                 testthat_2.1.1             
## [63] gtable_0.3.0                DBI_1.0.0                  
## [65] markdown_1.0                R6_2.4.0                   
## [67] zoo_1.8-6                   lubridate_1.7.4            
## [69] dplyr_0.8.1                 bit_1.1-14                 
## [71] rprojroot_1.3-2             readr_1.3.1                
## [73] desc_1.2.0                  stringi_1.4.3              
## [75] Rcpp_1.0.1                  tidyselect_0.2.5           
## [77] xfun_0.7
```

```r
Sys.time()
```

```
## [1] "2019-06-21 18:33:55 CDT"
```

