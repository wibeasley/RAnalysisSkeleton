



This report was automatically generated with the R package **knitr**
(version 1.25).


```r
# knitr::stitch_rmd(script="flow.R", output="stitched-output/flow.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
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
  "run_r"     , "manipulation/simulation/simulate-mlm-1.R",
  # "run_r"   , "manipulation/simulation/simulate-te.R",

  # First run the manipulation files to prepare the dataset(s).
  "run_r"     , "manipulation/car-ellis.R",
  "run_r"     , "manipulation/mlm-1-ellis.R",
  "run_r"     , "manipulation/te-ellis.R",
  "run_r"     , "manipulation/subject-1-ellis.R",

  # "run_sql" , "manipulation/inserts-to-normalized-tables.sql"
  "run_r"     , "manipulation/randomization-block-simple.R",

  # Scribes
  "run_r"     , "manipulation/mlm-1-scribe.R",
  "run_r"     , "manipulation/te-scribe.R",

  # Reports
  "run_rmd"   , "analysis/car-report-1/car-report-1.Rmd",
  "run_rmd"   , "analysis/report-te-1/report-te-1.Rmd"

  # Dashboards
  # "run_rmd" , "analysis/dashboard-1/dashboard-1.Rmd"
)

run_r <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  base::source(minion, local=new.env())
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_sql <- function( minion ) {
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
message("Starting flow of `", basename(base::getwd()), "` at ", Sys.time(), ".")
```

```
## Starting flow of `RAnalysisSkeleton` at 2019-10-29 13:35:41.
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
## Starting `simulate-mlm-1.R` at 2019-10-29 13:35:42.
```

```
## Loading required namespace: readr
```

```
## Loading required namespace: tidyr
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
## Starting `car-ellis.R` at 2019-10-29 13:35:43.
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
## Starting `mlm-1-ellis.R` at 2019-10-29 13:35:43.
```

```
## Completed `mlm-1-ellis.R`.
```

```
## 
## Starting `te-ellis.R` at 2019-10-29 13:35:43.
```

```
## Completed `te-ellis.R`.
```

```
## 
## Starting `subject-1-ellis.R` at 2019-10-29 13:35:44.
```

```
## Completed `subject-1-ellis.R`.
```

```
## 
## Starting `randomization-block-simple.R` at 2019-10-29 13:35:44.
```

```
## Completed `randomization-block-simple.R`.
```

```
## 
## Starting `mlm-1-scribe.R` at 2019-10-29 13:35:44.
```

```
## Loading required namespace: odbc
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
## Starting `te-scribe.R` at 2019-10-29 13:35:44.
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
## Starting `car-report-1.Rmd` at 2019-10-29 13:35:44.
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
## "C:/Program Files/RStudio/bin/pandoc/pandoc" +RTS -K512m -RTS car-report-1.utf8.md --to html4 --from markdown+autolink_bare_uris+tex_math_single_backslash+smart --output car-report-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template "D:\Projects\RLibraries\rmarkdown\rmd\h\default.html" --no-highlight --variable highlightjs=1 --number-sections --css "..\common\styles.css" --variable "theme:bootstrap" --include-in-header "C:\Users\Will\AppData\Local\Temp\Rtmp61vgw0\rmarkdown-str2154529c73ad.html" --mathjax --variable "mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" --lua-filter "D:/Projects/RLibraries/rmarkdown/rmd/lua/pagebreak.lua" --lua-filter "D:/Projects/RLibraries/rmarkdown/rmd/lua/latex-div.lua"
```

```
## 
## Output created: car-report-1.html
```

```
## D:/Users/Will/Documents/GitHub/RAnalysisSkeleton/analysis/car-report-1/car-report-1.html
```

```
## 
## Starting `report-te-1.Rmd` at 2019-10-29 13:35:56.
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
## "C:/Program Files/RStudio/bin/pandoc/pandoc" +RTS -K512m -RTS report-te-1.utf8.md --to html4 --from markdown+autolink_bare_uris+tex_math_single_backslash+smart --output report-te-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template "D:\Projects\RLibraries\rmarkdown\rmd\h\default.html" --no-highlight --variable highlightjs=1 --number-sections --css "..\common\styles.css" --variable "theme:bootstrap" --include-in-header "C:\Users\Will\AppData\Local\Temp\Rtmp61vgw0\rmarkdown-str215464527a0f.html" --mathjax --variable "mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" --lua-filter "D:/Projects/RLibraries/rmarkdown/rmd/lua/pagebreak.lua" --lua-filter "D:/Projects/RLibraries/rmarkdown/rmd/lua/latex-div.lua"
```

```
## 
## Output created: report-te-1.html
```

```
## D:/Users/Will/Documents/GitHub/RAnalysisSkeleton/analysis/report-te-1/report-te-1.html
```

```r
message("Completed flow of `", basename(base::getwd()), "` at ", Sys.time(), "")
```

```
## Completed flow of `RAnalysisSkeleton` at 2019-10-29 13:36:09
```

```r
elapsed_duration
```

```
##    user  system elapsed 
##   15.26    1.25   27.64
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
## R version 3.6.1 Patched (2019-08-12 r76979)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows >= 8 x64 (build 9200)
## 
## Matrix products: default
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] lme4_1.1-21   Matrix_1.2-17 knitr_1.25    ggplot2_3.2.1 magrittr_1.5 
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.2                  lubridate_1.7.4            
##  [3] lattice_0.20-38             tidyr_1.0.0                
##  [5] prettyunits_1.0.2           ps_1.3.0                   
##  [7] zoo_1.8-6                   assertthat_0.2.1           
##  [9] zeallot_0.1.0               rprojroot_1.3-2            
## [11] digest_0.6.22               packrat_0.5.0              
## [13] R6_2.4.0                    odbc_1.1.6                 
## [15] backports_1.1.5             RSQLite_2.1.2              
## [17] evaluate_0.14               highr_0.8                  
## [19] pillar_1.4.2                rlang_0.4.1                
## [21] lazyeval_0.2.2              minqa_1.2.4                
## [23] nloptr_1.2.1                callr_3.3.2                
## [25] blob_1.2.0                  checkmate_1.9.4            
## [27] rmarkdown_1.16              splines_3.6.1              
## [29] config_0.3                  desc_1.2.0                 
## [31] labeling_0.3                devtools_2.2.1             
## [33] readr_1.3.1                 stringr_1.4.0              
## [35] bit_1.1-14                  munsell_0.5.0              
## [37] compiler_3.6.1              xfun_0.10                  
## [39] pkgconfig_2.0.3             pkgbuild_1.0.6             
## [41] htmltools_0.4.0             tidyselect_0.2.5           
## [43] tibble_2.1.3                viridisLite_0.3.0          
## [45] crayon_1.3.4                dplyr_0.8.3                
## [47] withr_2.1.2                 MASS_7.3-51.4              
## [49] grid_3.6.1                  nlme_3.1-141               
## [51] gtable_0.3.0                lifecycle_0.1.0            
## [53] DBI_1.0.0                   scales_1.0.0               
## [55] TabularManifest_0.1-16.9003 cli_1.1.0                  
## [57] stringi_1.4.3               fs_1.3.1                   
## [59] remotes_2.1.0               testit_0.10                
## [61] testthat_2.2.1              ellipsis_0.3.0             
## [63] vctrs_0.2.0                 boot_1.3-23                
## [65] tools_3.6.1                 bit64_0.9-7                
## [67] OuhscMunge_0.1.9.9010       glue_1.3.1                 
## [69] purrr_0.3.3                 hms_0.5.1                  
## [71] processx_3.4.1              pkgload_1.0.2              
## [73] yaml_2.2.0                  colorspace_1.4-1           
## [75] sessioninfo_1.1.1           memoise_1.1.0              
## [77] usethis_1.5.1
```

```r
Sys.time()
```

```
## [1] "2019-10-29 13:36:09 CDT"
```

