



This report was automatically generated with the R package **knitr**
(version 1.21).


```r
# knitr::stitch_rmd(script="utility/reproduce.R", output="stitched-output/utility/reproduce.md")
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
  "run_rmd"       , "analysis/report-te-1/report-te-1.Rmd",

  # Dashboards
  "run_rmd"       , "analysis/dashboard-1/dashboard-1.Rmd"
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
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
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
## Starting update of files at 2019-02-27 21:16:27.
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
## Starting `simulate-mlm-1.R` at 2019-02-27 21:16:27.
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
## Starting `car-ellis.R` at 2019-02-27 21:16:29.
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
## Starting `mlm-1-ellis.R` at 2019-02-27 21:16:29.
```

```
## Completed `mlm-1-ellis.R`.
```

```
## 
## Starting `te-ellis.R` at 2019-02-27 21:16:30.
```

```
## Completed `te-ellis.R`.
```

```
## 
## Starting `subject-1-ellis.R` at 2019-02-27 21:16:30.
```

```
## Completed `subject-1-ellis.R`.
```

```
## 
## Starting `randomization-block-simple.R` at 2019-02-27 21:16:30.
```

```
## Completed `randomization-block-simple.R`.
```

```
## 
## Starting `mlm-1-scribe.R` at 2019-02-27 21:16:30.
```

```
## Loading required namespace: odbc
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
## Starting `te-scribe.R` at 2019-02-27 21:16:30.
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
## Starting `car-report-1.Rmd` at 2019-02-27 21:16:31.
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
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS car-report-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output car-report-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.5/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/RtmpoKZT9P/rmarkdown-str1a5732b6c7ab.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
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
## Starting `report-te-1.Rmd` at 2019-02-27 21:16:42.
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
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS report-te-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash+smart --output report-te-1.html --email-obfuscation none --self-contained --standalone --section-divs --table-of-contents --toc-depth 3 --variable toc_float=1 --variable toc_selectors=h1,h2,h3 --variable toc_collapsed=1 --variable toc_smooth_scroll=1 --variable toc_print=1 --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.5/rmarkdown/rmd/h/default.html --no-highlight --variable highlightjs=1 --number-sections --css ../common/styles.css --variable 'theme:bootstrap' --include-in-header /tmp/RtmpoKZT9P/rmarkdown-str1a577ffc67c6.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
```

```
## 
## Output created: report-te-1.html
```

```
## /home/wibeasley/Documents/wibeasley/RAnalysisSkeleton/analysis/report-te-1/report-te-1.html
```

```
## 
## Starting `dashboard-1.Rmd` at 2019-02-27 21:17:00.
```

```
## 
## 
## processing file: dashboard-1.Rmd
```

```
##   |                                                                         |                                                                 |   0%  |                                                                         |..                                                               |   3%
##   ordinary text without R code
## 
##   |                                                                         |....                                                             |   6%
## label: unnamed-chunk-1-2 (with options) 
## List of 2
##  $ echo   : symbol F
##  $ message: symbol F
## 
##   |                                                                         |.....                                                            |   8%
##   ordinary text without R code
## 
##   |                                                                         |.......                                                          |  11%
## label: set-options (with options) 
## List of 1
##  $ echo: symbol F
## 
##   |                                                                         |.........                                                        |  14%
##   ordinary text without R code
## 
##   |                                                                         |...........                                                      |  17%
## label: load-sources (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |.............                                                    |  19%
##   ordinary text without R code
## 
##   |                                                                         |..............                                                   |  22%
## label: load-packages (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
```

```
## 
## Attaching package: 'plotly'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     last_plot
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

```
## The following object is masked from 'package:graphics':
## 
##     layout
```

```
## Loading required namespace: broom
```

```
## Loading required namespace: kableExtra
```

```
##   |                                                                         |................                                                 |  25%
##   ordinary text without R code
## 
##   |                                                                         |..................                                               |  28%
## label: declare-globals (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |....................                                             |  31%
##   ordinary text without R code
## 
##   |                                                                         |......................                                           |  33%
## label: rmd-specific (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |.......................                                          |  36%
##   ordinary text without R code
## 
##   |                                                                         |.........................                                        |  39%
## label: load-data (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |...........................                                      |  42%
##   ordinary text without R code
## 
##   |                                                                         |.............................                                    |  44%
## label: tweak-data (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "show"
##  $ message: symbol message_chunks
## 
##   |                                                                         |...............................                                  |  47%
##    inline R code fragments
## 
##   |                                                                         |................................                                 |  50%
## label: headline-graph (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ results: chr "asis"
##  $ message: symbol message_chunks
```

```
##   |                                                                         |..................................                               |  53%
##   ordinary text without R code
## 
##   |                                                                         |....................................                             |  56%
## label: tables-county-year (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |......................................                           |  58%
##   ordinary text without R code
## 
##   |                                                                         |........................................                         |  61%
## label: tables-county (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |..........................................                       |  64%
##   ordinary text without R code
## 
##   |                                                                         |...........................................                      |  67%
## label: tables-annotation (with options) 
## List of 2
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
## 
##   |                                                                         |.............................................                    |  69%
##   ordinary text without R code
## 
##   |                                                                         |...............................................                  |  72%
## label: spaghetti (with options) 
## List of 5
##  $ echo      : symbol echo_chunks
##  $ message   : symbol message_chunks
##  $ results   : chr "asis"
##  $ fig.height: num 10
##  $ fig.width : num 20
```

```
##   |                                                                         |.................................................                |  75%
##   ordinary text without R code
## 
##   |                                                                         |...................................................              |  78%
## label: marginals (with options) 
## List of 3
##  $ echo   : symbol echo_chunks
##  $ message: symbol message_chunks
##  $ results: chr "asis"
## 
##   |                                                                         |....................................................             |  81%
##   ordinary text without R code
## 
##   |                                                                         |......................................................           |  83%
## label: unnamed-chunk-3 (with options) 
## List of 1
##  $ child: chr "../common/dashboard/documentation-all-dashboards-1.Rmd"
```

```
## 
## 
## processing file: ./../common/dashboard/documentation-all-dashboards-1.Rmd
```

```
##   |                                                                                                  |                                                                                          |   0%  |                                                                                                  |..........................................................................................| 100%
##   ordinary text without R code
## 
## 
##   |                                                                         |........................................................         |  86%
##   ordinary text without R code
## 
##   |                                                                         |..........................................................       |  89%
## label: unnamed-chunk-4 (with options) 
## List of 1
##  $ child: chr "../common/dashboard/documentation-glossary-1.Rmd"
```

```
## 
## 
## processing file: ./../common/dashboard/documentation-glossary-1.Rmd
```

```
##   |                                                                                                  |                                                                                          |   0%  |                                                                                                  |..........................................................................................| 100%
##   ordinary text without R code
## 
## 
##   |                                                                         |............................................................     |  92%
##   ordinary text without R code
## 
##   |                                                                         |.............................................................    |  94%
## label: unnamed-chunk-5 (with options) 
## List of 1
##  $ child: chr "../common/dashboard/documentation-tips-1.Rmd"
```

```
## 
## 
## processing file: ./../common/dashboard/documentation-tips-1.Rmd
```

```
##   |                                                                                                  |                                                                                          |   0%  |                                                                                                  |..........................................................................................| 100%
##   ordinary text without R code
## 
## 
##   |                                                                         |...............................................................  |  97%
##   ordinary text without R code
## 
##   |                                                                         |.................................................................| 100%
## label: unnamed-chunk-6 (with options) 
## List of 1
##  $ child: chr "../common/dashboard/documentation-config-1.Rmd"
```

```
## 
## 
## processing file: ./../common/dashboard/documentation-config-1.Rmd
```

```
##   |                                                                                                  |                                                                                          |   0%  |                                                                                                  |..................                                                                        |  20%
##   ordinary text without R code
## 
##   |                                                                                                  |....................................                                                      |  40%
## label: session-duration (with options) 
## List of 1
##  $ echo: logi FALSE
## 
##   |                                                                                                  |......................................................                                    |  60%
##    inline R code fragments
## 
##   |                                                                                                  |........................................................................                  |  80%
## label: session-info-2 (with options) 
## List of 1
##  $ echo: logi FALSE
## 
##   |                                                                                                  |..........................................................................................| 100%
##   ordinary text without R code
```

```
## output file: dashboard-1.knit.md
```

```
## /usr/lib/rstudio/bin/pandoc/pandoc +RTS -K512m -RTS dashboard-1.utf8.md --to html4 --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash --output dashboard-1.html --email-obfuscation none --self-contained --standalone --section-divs --template /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.5/flexdashboard/rmarkdown/templates/flex_dashboard/resources/default.html --include-in-header /tmp/RtmpoKZT9P/rmarkdown-str1a572b172c04.html --variable 'theme:journal' --include-in-header /tmp/RtmpoKZT9P/rmarkdown-str1a5732832f2.html --mathjax --variable 'mathjax-url:https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML' --include-in-header /tmp/RtmpoKZT9P/file1a576973be28html --include-before-body /tmp/RtmpoKZT9P/file1a578d4b98b.html --include-after-body /tmp/RtmpoKZT9P/file1a5721327b4f.html --highlight-style pygments --include-before-body /tmp/RtmpoKZT9P/file1a577bb53f26.html --include-after-body /tmp/RtmpoKZT9P/file1a573bbb0d84.html
```

```
## 
## Output created: dashboard-1.html
```

```
## /home/wibeasley/Documents/wibeasley/RAnalysisSkeleton/analysis/dashboard-1/dashboard-1.html
```

<img src="figure/reproduce-Rmdrun-1.png" title="plot of chunk run" alt="plot of chunk run" style="display: block; margin: auto;" />

```r
message("Completed update of files at ", Sys.time(), "")
```

```
## Completed update of files at 2019-02-27 21:17:20
```

```r
elapsed_time
```

```
##    user  system elapsed 
##  40.791   3.799  52.903
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.5.2 (2018-12-20)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 18.04.2 LTS
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
## [1] plotly_4.8.0.9000     flexdashboard_0.5.1.1 lme4_1.1-20          
## [4] Matrix_1.2-15         knitr_1.21            ggplot2_3.1.0        
## [7] magrittr_1.5         
## 
## loaded via a namespace (and not attached):
##  [1] nlme_3.1-137                fs_1.2.6                   
##  [3] usethis_1.4.0               lubridate_1.7.4            
##  [5] devtools_2.0.1              bit64_0.9-7                
##  [7] RColorBrewer_1.1-2          webshot_0.5.1              
##  [9] httr_1.4.0                  rprojroot_1.3-2            
## [11] tools_3.5.2                 backports_1.1.3            
## [13] DT_0.5                      R6_2.4.0                   
## [15] DBI_1.0.0                   lazyeval_0.2.1             
## [17] colorspace_1.4-0            withr_2.1.2                
## [19] tidyselect_0.2.5            prettyunits_1.0.2          
## [21] processx_3.2.1              bit_1.1-14                 
## [23] compiler_3.5.2              cli_1.0.1                  
## [25] rvest_0.3.2                 OuhscMunge_0.1.9.9010      
## [27] Cairo_1.5-9                 xml2_1.2.0                 
## [29] desc_1.2.0                  labeling_0.3               
## [31] scales_1.0.0.9000           checkmate_1.9.1            
## [33] readr_1.3.1                 callr_3.1.1                
## [35] odbc_1.1.6                  stringr_1.4.0              
## [37] digest_0.6.18               minqa_1.2.4                
## [39] rmarkdown_1.11              pkgconfig_2.0.2            
## [41] htmltools_0.3.6             sessioninfo_1.1.1          
## [43] highr_0.7                   htmlwidgets_1.3            
## [45] rlang_0.3.1                 rstudioapi_0.9.0           
## [47] RSQLite_2.1.1               shiny_1.2.0                
## [49] generics_0.0.2              zoo_1.8-4                  
## [51] testit_0.9                  jsonlite_1.6               
## [53] crosstalk_1.0.0             dplyr_0.8.0.1              
## [55] config_0.3                  kableExtra_1.0.1           
## [57] Rcpp_1.0.0                  munsell_0.5.0              
## [59] stringi_1.3.1               yaml_2.2.0                 
## [61] MASS_7.3-51.1               pkgbuild_1.0.2             
## [63] plyr_1.8.4                  grid_3.5.2                 
## [65] blob_1.1.1                  promises_1.0.1             
## [67] crayon_1.3.4                lattice_0.20-38            
## [69] splines_3.5.2               hms_0.4.2.9001             
## [71] ps_1.3.0                    pillar_1.3.1               
## [73] pkgload_1.0.2               TabularManifest_0.1-16.9003
## [75] glue_1.3.0                  packrat_0.5.0              
## [77] evaluate_0.13               data.table_1.12.0          
## [79] remotes_2.0.2               httpuv_1.4.5.1             
## [81] nloptr_1.2.1                testthat_2.0.1             
## [83] gtable_0.2.0                purrr_0.3.0                
## [85] tidyr_0.8.2                 assertthat_0.2.0           
## [87] xfun_0.5                    mime_0.6                   
## [89] xtable_1.8-3                broom_0.5.1                
## [91] later_0.8.0                 viridisLite_0.3.0          
## [93] RcppRoll_0.3.0              tibble_2.0.1               
## [95] memoise_1.1.0
```

```r
Sys.time()
```

```
## [1] "2019-02-27 21:17:23 CST"
```

