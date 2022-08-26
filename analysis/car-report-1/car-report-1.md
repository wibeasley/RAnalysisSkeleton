---
title: Skeleton Report 1
date: "Date: 2022-08-26"
output:
  # radix::radix_article: # radix is a newer alternative that has some advantages over `html_document`.
  html_document:
    keep_md: yes
    toc: 4
    toc_float: true
    number_sections: true
    css: ../common/styles.css         # analysis/common/styles.css
---

This report covers the analyses used in the ZZZ project (Marcus Mark, PI).

<!--  Set the working directory to the repository's base directory; this assumes the report is nested inside of two directories.-->


<!-- Set the report-wide options, and point to the external code file. -->


<!-- Load 'sourced' R files.  Suppress the output when loading sources. -->


<!-- Load packages, or at least verify they're available on the local machine.  Suppress the output when loading packages. -->


<!-- Load any global functions and variables declared in the R file.  Suppress the output. -->


<!-- Declare any global functions specific to a Rmd output.  Suppress the output. -->


<!-- Load the datasets.   -->


<!-- Tweak the datasets.   -->


Summary {.tabset .tabset-fade .tabset-pills}
===========================================================================

Notes
---------------------------------------------------------------------------

1. The current report covers 32 cars, with 6 unique values for `carburetor_count`.
1. The Seattle track's phluguerstometer was producing flaky negative values; it's measurements have been dropped.


Unanswered Questions
---------------------------------------------------------------------------

1. What does `VS` stand for?  How was it measured?
1. Where the cars at the Philly track measured with the same phluguerstometer and the Cleveland track?


Answered Questions
---------------------------------------------------------------------------

1. The Seattle track's phluguerstometer was producing flaky negative values; it's measurements have been dropped.


Graphs
===========================================================================


Marginals
---------------------------------------------------------------------------

![](figure-png/marginals-1.png)<!-- -->![](figure-png/marginals-2.png)<!-- -->![](figure-png/marginals-3.png)<!-- -->![](figure-png/marginals-4.png)<!-- -->


Scatterplots
---------------------------------------------------------------------------

![](figure-png/scatterplots-1.png)<!-- -->![](figure-png/scatterplots-2.png)<!-- -->![](figure-png/scatterplots-3.png)<!-- -->![](figure-png/scatterplots-4.png)<!-- -->![](figure-png/scatterplots-5.png)<!-- -->


Models
===========================================================================

Model Exploration
---------------------------------------------------------------------------

```
============= Simple model that's just an intercept. =============
```

```

Call:
lm(formula = quarter_mile_sec ~ 1, data = ds)

Residuals:
    Min      1Q  Median      3Q     Max 
-3.3487 -0.9563 -0.1387  1.0512  5.0512 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)  17.8488     0.3159    56.5   <2e-16

Residual standard error: 1.787 on 31 degrees of freedom
```

```
============= Model includes one predictor. =============
```

```

Call:
lm(formula = quarter_mile_sec ~ 1 + miles_per_gallon, data = ds)

Residuals:
    Min      1Q  Median      3Q     Max 
-2.8161 -1.0287  0.0954  0.8623  4.7149 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)
(Intercept)      15.35477    1.02978  14.911 2.05e-15
miles_per_gallon  0.12414    0.04916   2.525   0.0171

Residual standard error: 1.65 on 30 degrees of freedom
Multiple R-squared:  0.1753,	Adjusted R-squared:  0.1478 
F-statistic: 6.377 on 1 and 30 DF,  p-value: 0.01708
```

```
The one predictor is significantly tighter.
```

```
Analysis of Variance Table

Model 1: quarter_mile_sec ~ 1
Model 2: quarter_mile_sec ~ 1 + miles_per_gallon
  Res.Df    RSS Df Sum of Sq      F  Pr(>F)
1     31 98.988                            
2     30 81.636  1    17.352 6.3767 0.01708
```

```
============= Model includes two predictors. =============
```

```

Call:
lm(formula = quarter_mile_sec ~ 1 + miles_per_gallon + forward_gear_count_f, 
    data = ds)

Residuals:
    Min      1Q  Median      3Q     Max 
-2.0370 -0.5882 -0.1602  0.5428  4.1646 

Coefficients:
                         Estimate Std. Error t value Pr(>|t|)
(Intercept)              15.55851    0.89782  17.329  < 2e-16
miles_per_gallon          0.13246    0.05164   2.565 0.015963
forward_gear_count_fFour  0.15680    0.66819   0.235 0.816173
forward_gear_count_fFive -2.75051    0.72888  -3.774 0.000768

Residual standard error: 1.309 on 28 degrees of freedom
Multiple R-squared:  0.5151,	Adjusted R-squared:  0.4632 
F-statistic: 9.916 on 3 and 28 DF,  p-value: 0.0001272
```

```
The two predictor is significantly tighter.
```

```
Analysis of Variance Table

Model 1: quarter_mile_sec ~ 1 + miles_per_gallon
Model 2: quarter_mile_sec ~ 1 + miles_per_gallon + forward_gear_count_f
  Res.Df    RSS Df Sum of Sq      F    Pr(>F)
1     30 81.636                              
2     28 47.996  2     33.64 9.8124 0.0005896
```


Final Model
---------------------------------------------------------------------------


|                         | Estimate| Std. Error| t value| Pr(>&#124;t&#124;)|
|:------------------------|--------:|----------:|-------:|------------------:|
|(Intercept)              |    15.56|       0.90|   17.33|               0.00|
|miles_per_gallon         |     0.13|       0.05|    2.57|               0.02|
|forward_gear_count_fFour |     0.16|       0.67|    0.23|               0.82|
|forward_gear_count_fFive |    -2.75|       0.73|   -3.77|               0.00|

In the model that includes two predictors, the slope coefficent of `Miles per gallon` is 0.13246.


Session Information {#session-info}
===========================================================================

For the sake of documentation and reproducibility, the current report was rendered in the following environment.  Click the line below to expand.

<details>
  <summary>Environment <span class="glyphicon glyphicon-plus-sign"></span></summary>

```
- Session info -----------------------------------------------------------------------------
 setting  value
 version  R version 4.2.1 Patched (2022-07-09 r82577 ucrt)
 os       Windows >= 8 x64 (build 9200)
 system   x86_64, mingw32
 ui       RStudio
 language (EN)
 collate  English_United States.1252
 ctype    English_United States.1252
 tz       America/Chicago
 date     2022-08-26
 rstudio  2022.07.0+548 Spotted Wakerobin (desktop)
 pandoc   2.18 @ C:/Program Files/RStudio/bin/quarto/bin/tools/ (via rmarkdown)

- Packages ---------------------------------------------------------------------------------
 ! package           * version     date (UTC) lib source
 D archive             1.1.5       2022-05-06 [1] CRAN (R 4.2.0)
   assertthat          0.2.1       2019-03-21 [1] CRAN (R 4.2.0)
   backports           1.4.1       2021-12-13 [1] CRAN (R 4.2.0)
   bit                 4.0.4       2020-08-04 [1] CRAN (R 4.2.0)
   bit64               4.0.5       2020-08-30 [1] CRAN (R 4.2.0)
   blob                1.2.3       2022-04-10 [1] CRAN (R 4.2.0)
   boot                1.3-28      2021-05-03 [3] CRAN (R 4.2.1)
   brio                1.1.3       2021-11-30 [1] CRAN (R 4.2.0)
   bslib               0.4.0       2022-07-16 [1] CRAN (R 4.2.1)
   cachem              1.0.6       2021-08-19 [1] CRAN (R 4.2.0)
   callr               3.7.2       2022-08-22 [1] CRAN (R 4.2.1)
   checkmate           2.1.0       2022-04-21 [1] CRAN (R 4.2.0)
   cli                 3.3.0       2022-04-25 [1] CRAN (R 4.2.0)
   clisymbols          1.2.0       2017-05-21 [1] CRAN (R 4.2.0)
   colorspace          2.0-3       2022-02-21 [1] CRAN (R 4.2.0)
   config              0.3.1       2020-12-17 [1] CRAN (R 4.2.0)
   covr                3.5.1       2020-09-16 [1] CRAN (R 4.2.0)
   crayon              1.5.1       2022-03-26 [1] CRAN (R 4.2.0)
   curl                4.3.2       2021-06-23 [1] CRAN (R 4.1.0)
   cyclocomp           1.1.0       2016-09-10 [1] CRAN (R 4.2.0)
   DBI                 1.1.3       2022-06-18 [1] CRAN (R 4.2.0)
   desc                1.4.1       2022-03-06 [1] CRAN (R 4.2.0)
   devtools            2.4.4       2022-07-20 [1] CRAN (R 4.2.1)
   digest              0.6.29      2021-12-01 [1] CRAN (R 4.1.2)
   dplyr               1.0.9       2022-04-28 [1] CRAN (R 4.2.0)
   ellipsis            0.3.2       2021-04-29 [1] CRAN (R 4.1.0)
   evaluate            0.16        2022-08-09 [1] CRAN (R 4.2.1)
   fansi               1.0.3       2022-03-24 [1] CRAN (R 4.1.3)
   farver              2.1.1       2022-07-06 [1] CRAN (R 4.2.1)
   fastmap             1.1.0       2021-01-25 [1] CRAN (R 4.1.0)
   forcats             0.5.2       2022-08-19 [1] CRAN (R 4.2.1)
   fs                  1.5.2       2021-12-08 [1] CRAN (R 4.1.2)
   generics            0.1.3       2022-07-05 [1] CRAN (R 4.2.1)
   ggplot2           * 3.3.6       2022-05-03 [1] CRAN (R 4.2.0)
   glue                1.6.2       2022-02-24 [1] CRAN (R 4.1.2)
   goodpractice        1.0.3       2022-07-13 [1] CRAN (R 4.2.1)
   gtable              0.3.0       2019-03-25 [1] CRAN (R 4.2.0)
   highr               0.9         2021-04-16 [1] CRAN (R 4.2.0)
   hms                 1.1.2       2022-08-19 [1] CRAN (R 4.2.1)
   htmltools           0.5.3       2022-07-18 [1] CRAN (R 4.2.1)
   htmlwidgets         1.5.4       2021-09-08 [1] CRAN (R 4.2.0)
   httpuv              1.6.5       2022-01-05 [1] CRAN (R 4.2.0)
   httr                1.4.4       2022-08-17 [1] CRAN (R 4.2.1)
   import              1.3.0       2022-05-23 [1] CRAN (R 4.2.0)
   jquerylib           0.1.4       2021-04-26 [1] CRAN (R 4.2.0)
   jsonlite            1.8.0       2022-02-22 [1] CRAN (R 4.1.2)
   knitr             * 1.39        2022-04-26 [1] CRAN (R 4.2.0)
   labeling            0.4.2       2020-10-20 [1] CRAN (R 4.2.0)
   later               1.3.0       2021-08-18 [1] CRAN (R 4.2.0)
   lattice             0.20-45     2021-09-22 [3] CRAN (R 4.2.1)
   lazyeval            0.2.2       2019-03-15 [1] CRAN (R 4.2.0)
   lifecycle           1.0.1       2021-09-24 [1] CRAN (R 4.2.0)
   lintr               3.0.0       2022-06-13 [1] CRAN (R 4.2.0)
   lme4              * 1.1-30      2022-07-08 [1] CRAN (R 4.2.1)
   lubridate           1.8.0       2021-10-07 [1] CRAN (R 4.2.0)
   magrittr            2.0.3       2022-03-30 [1] CRAN (R 4.1.3)
   MASS                7.3-57      2022-04-22 [3] CRAN (R 4.2.1)
   Matrix            * 1.4-1       2022-03-23 [1] CRAN (R 4.2.0)
   memoise             2.0.1       2021-11-26 [1] CRAN (R 4.2.0)
   mgcv                1.8-40      2022-03-29 [1] CRAN (R 4.2.0)
   mime                0.12        2021-09-28 [1] CRAN (R 4.2.0)
   miniUI              0.1.1.1     2018-05-18 [1] CRAN (R 4.2.0)
   minqa               1.2.4       2014-10-09 [1] CRAN (R 4.2.0)
   munsell             0.5.0       2018-06-12 [1] CRAN (R 4.2.0)
   nlme                3.1-158     2022-06-15 [3] CRAN (R 4.2.1)
   nloptr              2.0.3       2022-05-26 [1] CRAN (R 4.2.0)
   odbc                1.3.3       2021-11-30 [1] CRAN (R 4.2.0)
   OuhscMunge          0.2.0.9015  2021-10-20 [1] Github (OuhscBbmc/OuhscMunge@4e04b6f)
   pillar              1.8.1       2022-08-19 [1] CRAN (R 4.2.1)
   pkgbuild            1.3.1       2021-12-20 [1] CRAN (R 4.2.0)
   pkgconfig           2.0.3       2019-09-22 [1] CRAN (R 4.2.0)
   pkgdown             2.0.6       2022-07-16 [1] CRAN (R 4.2.1)
   pkgload             1.3.0       2022-06-27 [1] CRAN (R 4.2.1)
   png                 0.1-7       2013-12-03 [1] CRAN (R 4.2.0)
   praise              1.0.0       2015-08-11 [1] CRAN (R 4.2.0)
   prettyunits         1.1.1       2020-01-24 [1] CRAN (R 4.2.0)
   processx            3.7.0       2022-07-07 [1] CRAN (R 4.2.1)
   profvis             0.3.7       2020-11-02 [1] CRAN (R 4.2.0)
   promises            1.2.0.1     2021-02-11 [1] CRAN (R 4.2.0)
   ps                  1.7.1       2022-06-18 [1] CRAN (R 4.2.0)
   purrr               0.3.4       2020-04-17 [1] CRAN (R 4.1.0)
   R6                  2.5.1       2021-08-19 [1] CRAN (R 4.2.0)
   RAnalysisSkeleton   1.0.0       2022-06-25 [1] local
   rcmdcheck           1.4.0       2021-09-27 [1] CRAN (R 4.2.0)
   Rcpp                1.0.9       2022-07-08 [1] CRAN (R 4.2.1)
   readr               2.1.2       2022-01-30 [1] CRAN (R 4.2.0)
   remotes             2.4.2       2021-11-30 [1] CRAN (R 4.2.0)
   reticulate          1.25        2022-05-11 [1] CRAN (R 4.2.0)
   rex                 1.2.1       2021-11-26 [1] CRAN (R 4.2.0)
   rlang               1.0.4       2022-07-12 [1] CRAN (R 4.2.1)
   rmarkdown           2.15        2022-08-16 [1] CRAN (R 4.2.1)
   rprojroot           2.0.3       2022-04-02 [1] CRAN (R 4.2.0)
   RSQLite           * 2.2.16      2022-08-17 [1] CRAN (R 4.2.1)
 V rstudioapi          0.13        2022-08-22 [1] CRAN (R 4.2.1) (on disk 0.14)
   sass                0.4.2       2022-07-16 [1] CRAN (R 4.2.1)
   scales              1.2.1       2022-08-20 [1] CRAN (R 4.2.1)
   sessioninfo         1.2.2       2021-12-06 [1] CRAN (R 4.2.0)
   shiny               1.7.2       2022-07-19 [1] CRAN (R 4.2.1)
   spelling            2.2         2020-10-18 [1] CRAN (R 4.2.0)
   stringi             1.7.8       2022-07-11 [1] CRAN (R 4.2.1)
   stringr             1.4.1       2022-08-20 [1] CRAN (R 4.2.1)
   TabularManifest     0.1-16.9003 2022-05-04 [1] Github (Melinae/TabularManifest@b966a2b)
   testit              0.13        2021-04-14 [1] CRAN (R 4.2.0)
   testthat            3.1.4       2022-04-26 [1] CRAN (R 4.1.3)
   tibble              3.1.8       2022-07-22 [1] CRAN (R 4.2.1)
   tidyr               1.2.0       2022-02-01 [1] CRAN (R 4.2.0)
   tidyselect          1.1.2       2022-02-21 [1] CRAN (R 4.2.0)
   tzdb                0.3.0       2022-03-28 [1] CRAN (R 4.2.0)
   urlchecker          1.0.1       2021-11-30 [1] CRAN (R 4.2.0)
   usethis             2.1.6       2022-05-25 [1] CRAN (R 4.2.0)
   utf8                1.2.2       2021-07-24 [1] CRAN (R 4.1.0)
   vctrs               0.4.1       2022-04-13 [1] CRAN (R 4.1.3)
   viridisLite         0.4.1       2022-08-22 [1] CRAN (R 4.2.1)
   vroom               1.5.7       2021-11-30 [1] CRAN (R 4.2.0)
   whoami              1.3.0       2019-03-19 [1] CRAN (R 4.2.0)
   withr               2.5.0       2022-03-03 [1] CRAN (R 4.2.0)
   xfun                0.32        2022-08-10 [1] CRAN (R 4.2.1)
   xml2                1.3.3       2021-11-30 [1] CRAN (R 4.2.0)
   xmlparsedata        1.0.5       2021-03-06 [1] CRAN (R 4.2.0)
   xopen               1.0.0       2018-09-17 [1] CRAN (R 4.2.0)
   xtable              1.8-4       2019-04-21 [1] CRAN (R 4.2.0)
   yaml                2.3.5       2022-02-21 [1] CRAN (R 4.2.0)
   zoo                 1.8-10      2022-04-15 [1] CRAN (R 4.2.0)

 [1] D:/Projects/RLibraries
 [2] C:/Users/Will/AppData/Local/R/win-library/4.2
 [3] C:/Program Files/R/R-4.2.1patched/library

 V -- Loaded and on-disk version mismatch.
 D -- DLL MD5 mismatch, broken installation.

--------------------------------------------------------------------------------------------
```
</details>



Report rendered by Will at 2022-08-26, 12:57 -0500 in 4 seconds.
