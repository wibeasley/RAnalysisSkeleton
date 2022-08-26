---
title: Time and Effort Report 1
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

1. The current report covers 3080 county-months, with 77 unique values for `county_id`.
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
Especially for the histograms, don't feel like each graph should be profound.
Boring sanity checks are useful,
such as the histogram of county names,
verifies there are ~77 different values (although they're mostly unreadable).


Marginals County
---------------------------------------------------------------------------

![](figure-png/marginals-county-1.png)<!-- -->![](figure-png/marginals-county-2.png)<!-- -->![](figure-png/marginals-county-3.png)<!-- -->![](figure-png/marginals-county-4.png)<!-- -->![](figure-png/marginals-county-5.png)<!-- -->![](figure-png/marginals-county-6.png)<!-- -->![](figure-png/marginals-county-7.png)<!-- -->![](figure-png/marginals-county-8.png)<!-- -->![](figure-png/marginals-county-9.png)<!-- -->

Marginals County-Month
---------------------------------------------------------------------------

![](figure-png/marginals-county-month-1.png)<!-- -->![](figure-png/marginals-county-month-2.png)<!-- -->![](figure-png/marginals-county-month-3.png)<!-- -->


Scatterplots
---------------------------------------------------------------------------

![](figure-png/scatterplots-1.png)<!-- -->![](figure-png/scatterplots-2.png)<!-- -->

```
$y
[1] "Sum of FTE for County"

$title
[1] "Zoomed: FTE sum each month (by county)"

attr(,"class")
[1] "labels"
```


Models
===========================================================================

Model Exploration
---------------------------------------------------------------------------

```
============= Simple model that's just an intercept. =============
```

```

Call:
lm(formula = fte ~ 1, data = ds_county_month)

Residuals:
    Min      1Q  Median      3Q     Max 
-1.6801 -1.6801 -0.6801  0.3199 24.8199 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)  1.68012    0.06074   27.66   <2e-16

Residual standard error: 3.371 on 3079 degrees of freedom
```

```
============= Model includes one predictor (ie, month). =============
```

```

Call:
lm(formula = fte ~ 1 + month, data = ds_county_month)

Residuals:
    Min      1Q  Median      3Q     Max 
-1.7997 -1.5990 -0.7322  0.2863 24.9208 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)
(Intercept) -1.5619680  2.7859569  -0.561    0.575
month        0.0002014  0.0001730   1.164    0.245

Residual standard error: 3.371 on 3078 degrees of freedom
Multiple R-squared:  0.00044,	Adjusted R-squared:  0.0001153 
F-statistic: 1.355 on 1 and 3078 DF,  p-value: 0.2445
```

```
The one predictor is NOT significantly tighter.
```

```
Analysis of Variance Table

Model 1: fte ~ 1
Model 2: fte ~ 1 + month
  Res.Df   RSS Df Sum of Sq      F Pr(>F)
1   3079 34989                           
2   3078 34974  1    15.395 1.3549 0.2445
```

```
============= MLM for county. =============
```

```
Linear mixed model fit by REML ['lmerMod']
Formula: fte ~ 1 + (1 | county)
   Data: ds_county_month

REML criterion at convergence: 5210.2

Scaled residuals: 
    Min      1Q  Median      3Q     Max 
-5.9382 -0.6584 -0.0019  0.4365  9.6331 

Random effects:
 Groups   Name        Variance Std.Dev.
 county   (Intercept) 11.242   3.3530  
 Residual              0.264   0.5138  
Number of obs: 3080, groups:  county, 77

Fixed effects:
            Estimate Std. Error t value
(Intercept)   1.6801     0.3822   4.396
```

```
============= MLM adds month. =============
```

```
Linear mixed model fit by REML ['lmerMod']
Formula: fte ~ 1 + month + (1 | county)
   Data: ds_county_month

REML criterion at convergence: 5170.6

Scaled residuals: 
    Min      1Q  Median      3Q     Max 
-5.9782 -0.5621 -0.0094  0.4683  9.9245 

Random effects:
 Groups   Name        Variance Std.Dev.
 county   (Intercept) 11.2424  3.3530  
 Residual              0.2589  0.5088  
Number of obs: 3080, groups:  county, 77

Fixed effects:
              Estimate Std. Error t value
(Intercept) -1.562e+00  5.682e-01  -2.749
month        2.014e-04  2.612e-05   7.711

Correlation of Fixed Effects:
      (Intr)
month -0.740
```

```
Including the Month predictor in the MLM is significantly tighter.
```

```
Data: ds_county_month
Models:
m2: fte ~ 1 + (1 | county)
m3: fte ~ 1 + month + (1 | county)
   npar    AIC    BIC  logLik deviance  Chisq Df Pr(>Chisq)
m2    3 5216.1 5234.2 -2605.1   5210.1                     
m3    4 5159.2 5183.3 -2575.6   5151.2 58.899  1   1.66e-14
```


Final Model
---------------------------------------------------------------------------


|            | Estimate| Std. Error| t value|
|:-----------|--------:|----------:|-------:|
|(Intercept) |    -1.56|       0.57|   -2.75|
|month       |     0.00|       0.00|    7.71|

In the MLM that includes time, the slope coefficent of `month` is 2.013797\times 10^{-4}.


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
 ! package         * version     date (UTC) lib source
 D archive           1.1.5       2022-05-06 [1] CRAN (R 4.2.0)
   assertthat        0.2.1       2019-03-21 [1] CRAN (R 4.2.0)
   backports         1.4.1       2021-12-13 [1] CRAN (R 4.2.0)
   bit               4.0.4       2020-08-04 [1] CRAN (R 4.2.0)
   bit64             4.0.5       2020-08-30 [1] CRAN (R 4.2.0)
   blob              1.2.3       2022-04-10 [1] CRAN (R 4.2.0)
   boot              1.3-28      2021-05-03 [3] CRAN (R 4.2.1)
   bslib             0.4.0       2022-07-16 [1] CRAN (R 4.2.1)
   cachem            1.0.6       2021-08-19 [1] CRAN (R 4.2.0)
   callr             3.7.2       2022-08-22 [1] CRAN (R 4.2.1)
   checkmate         2.1.0       2022-04-21 [1] CRAN (R 4.2.0)
   cli               3.3.0       2022-04-25 [1] CRAN (R 4.2.0)
   colorspace        2.0-3       2022-02-21 [1] CRAN (R 4.2.0)
   config            0.3.1       2020-12-17 [1] CRAN (R 4.2.0)
   crayon            1.5.1       2022-03-26 [1] CRAN (R 4.2.0)
   DBI               1.1.3       2022-06-18 [1] CRAN (R 4.2.0)
   devtools          2.4.4       2022-07-20 [1] CRAN (R 4.2.1)
   digest            0.6.29      2021-12-01 [1] CRAN (R 4.1.2)
   dplyr             1.0.9       2022-04-28 [1] CRAN (R 4.2.0)
   ellipsis          0.3.2       2021-04-29 [1] CRAN (R 4.1.0)
   evaluate          0.16        2022-08-09 [1] CRAN (R 4.2.1)
   fansi             1.0.3       2022-03-24 [1] CRAN (R 4.1.3)
   farver            2.1.1       2022-07-06 [1] CRAN (R 4.2.1)
   fastmap           1.1.0       2021-01-25 [1] CRAN (R 4.1.0)
   forcats           0.5.2       2022-08-19 [1] CRAN (R 4.2.1)
   fs                1.5.2       2021-12-08 [1] CRAN (R 4.1.2)
   generics          0.1.3       2022-07-05 [1] CRAN (R 4.2.1)
   ggplot2         * 3.3.6       2022-05-03 [1] CRAN (R 4.2.0)
   glue              1.6.2       2022-02-24 [1] CRAN (R 4.1.2)
   gtable            0.3.0       2019-03-25 [1] CRAN (R 4.2.0)
   highr             0.9         2021-04-16 [1] CRAN (R 4.2.0)
   hms               1.1.2       2022-08-19 [1] CRAN (R 4.2.1)
   htmltools         0.5.3       2022-07-18 [1] CRAN (R 4.2.1)
   htmlwidgets       1.5.4       2021-09-08 [1] CRAN (R 4.2.0)
   httpuv            1.6.5       2022-01-05 [1] CRAN (R 4.2.0)
   import            1.3.0       2022-05-23 [1] CRAN (R 4.2.0)
   jquerylib         0.1.4       2021-04-26 [1] CRAN (R 4.2.0)
   jsonlite          1.8.0       2022-02-22 [1] CRAN (R 4.1.2)
   knitr           * 1.39        2022-04-26 [1] CRAN (R 4.2.0)
   labeling          0.4.2       2020-10-20 [1] CRAN (R 4.2.0)
   later             1.3.0       2021-08-18 [1] CRAN (R 4.2.0)
   lattice           0.20-45     2021-09-22 [3] CRAN (R 4.2.1)
   lifecycle         1.0.1       2021-09-24 [1] CRAN (R 4.2.0)
   lme4            * 1.1-30      2022-07-08 [1] CRAN (R 4.2.1)
   lubridate         1.8.0       2021-10-07 [1] CRAN (R 4.2.0)
   magrittr          2.0.3       2022-03-30 [1] CRAN (R 4.1.3)
   MASS              7.3-57      2022-04-22 [3] CRAN (R 4.2.1)
   Matrix          * 1.4-1       2022-03-23 [1] CRAN (R 4.2.0)
   memoise           2.0.1       2021-11-26 [1] CRAN (R 4.2.0)
   mgcv              1.8-40      2022-03-29 [1] CRAN (R 4.2.0)
   mime              0.12        2021-09-28 [1] CRAN (R 4.2.0)
   miniUI            0.1.1.1     2018-05-18 [1] CRAN (R 4.2.0)
   minqa             1.2.4       2014-10-09 [1] CRAN (R 4.2.0)
   munsell           0.5.0       2018-06-12 [1] CRAN (R 4.2.0)
   nlme              3.1-158     2022-06-15 [3] CRAN (R 4.2.1)
   nloptr            2.0.3       2022-05-26 [1] CRAN (R 4.2.0)
   odbc              1.3.3       2021-11-30 [1] CRAN (R 4.2.0)
   OuhscMunge        0.2.0.9015  2021-10-20 [1] Github (OuhscBbmc/OuhscMunge@4e04b6f)
   pillar            1.8.1       2022-08-19 [1] CRAN (R 4.2.1)
   pkgbuild          1.3.1       2021-12-20 [1] CRAN (R 4.2.0)
   pkgconfig         2.0.3       2019-09-22 [1] CRAN (R 4.2.0)
   pkgload           1.3.0       2022-06-27 [1] CRAN (R 4.2.1)
   png               0.1-7       2013-12-03 [1] CRAN (R 4.2.0)
   prettyunits       1.1.1       2020-01-24 [1] CRAN (R 4.2.0)
   processx          3.7.0       2022-07-07 [1] CRAN (R 4.2.1)
   profvis           0.3.7       2020-11-02 [1] CRAN (R 4.2.0)
   promises          1.2.0.1     2021-02-11 [1] CRAN (R 4.2.0)
   ps                1.7.1       2022-06-18 [1] CRAN (R 4.2.0)
   purrr             0.3.4       2020-04-17 [1] CRAN (R 4.1.0)
   R6                2.5.1       2021-08-19 [1] CRAN (R 4.2.0)
   Rcpp              1.0.9       2022-07-08 [1] CRAN (R 4.2.1)
   readr             2.1.2       2022-01-30 [1] CRAN (R 4.2.0)
   remotes           2.4.2       2021-11-30 [1] CRAN (R 4.2.0)
   reticulate        1.25        2022-05-11 [1] CRAN (R 4.2.0)
   rlang             1.0.4       2022-07-12 [1] CRAN (R 4.2.1)
   rmarkdown         2.15        2022-08-16 [1] CRAN (R 4.2.1)
   RSQLite         * 2.2.16      2022-08-17 [1] CRAN (R 4.2.1)
 V rstudioapi        0.13        2022-08-22 [1] CRAN (R 4.2.1) (on disk 0.14)
   sass              0.4.2       2022-07-16 [1] CRAN (R 4.2.1)
   scales            1.2.1       2022-08-20 [1] CRAN (R 4.2.1)
   sessioninfo       1.2.2       2021-12-06 [1] CRAN (R 4.2.0)
   shiny             1.7.2       2022-07-19 [1] CRAN (R 4.2.1)
   stringi           1.7.8       2022-07-11 [1] CRAN (R 4.2.1)
   stringr           1.4.1       2022-08-20 [1] CRAN (R 4.2.1)
   TabularManifest   0.1-16.9003 2022-05-04 [1] Github (Melinae/TabularManifest@b966a2b)
   testit            0.13        2021-04-14 [1] CRAN (R 4.2.0)
   tibble            3.1.8       2022-07-22 [1] CRAN (R 4.2.1)
   tidyr             1.2.0       2022-02-01 [1] CRAN (R 4.2.0)
   tidyselect        1.1.2       2022-02-21 [1] CRAN (R 4.2.0)
   tzdb              0.3.0       2022-03-28 [1] CRAN (R 4.2.0)
   urlchecker        1.0.1       2021-11-30 [1] CRAN (R 4.2.0)
   usethis           2.1.6       2022-05-25 [1] CRAN (R 4.2.0)
   utf8              1.2.2       2021-07-24 [1] CRAN (R 4.1.0)
   vctrs             0.4.1       2022-04-13 [1] CRAN (R 4.1.3)
   viridisLite       0.4.1       2022-08-22 [1] CRAN (R 4.2.1)
   vroom             1.5.7       2021-11-30 [1] CRAN (R 4.2.0)
   withr             2.5.0       2022-03-03 [1] CRAN (R 4.2.0)
   xfun              0.32        2022-08-10 [1] CRAN (R 4.2.1)
   xtable            1.8-4       2019-04-21 [1] CRAN (R 4.2.0)
   yaml              2.3.5       2022-02-21 [1] CRAN (R 4.2.0)
   zoo               1.8-10      2022-04-15 [1] CRAN (R 4.2.0)

 [1] D:/Projects/RLibraries
 [2] C:/Users/Will/AppData/Local/R/win-library/4.2
 [3] C:/Program Files/R/R-4.2.1patched/library

 V -- Loaded and on-disk version mismatch.
 D -- DLL MD5 mismatch, broken installation.

--------------------------------------------------------------------------------------------
```
</details>



Report rendered by Will at 2022-08-26, 12:26 -0500 in 10 seconds.
