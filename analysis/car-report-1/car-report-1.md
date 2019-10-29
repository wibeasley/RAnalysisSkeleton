---
title: Skeleton Report 1
date: "Date: 2019-10-29"
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

<img src="figure-png/marginals-1.png" style="display: block; margin: auto;" /><img src="figure-png/marginals-2.png" style="display: block; margin: auto;" /><img src="figure-png/marginals-3.png" style="display: block; margin: auto;" /><img src="figure-png/marginals-4.png" style="display: block; margin: auto;" />


Scatterplots
---------------------------------------------------------------------------

<img src="figure-png/scatterplots-1.png" style="display: block; margin: auto;" /><img src="figure-png/scatterplots-2.png" style="display: block; margin: auto;" /><img src="figure-png/scatterplots-3.png" style="display: block; margin: auto;" /><img src="figure-png/scatterplots-4.png" style="display: block; margin: auto;" /><img src="figure-png/scatterplots-5.png" style="display: block; margin: auto;" />


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
- Session info ----------------------------------------------------------
 setting  value                                      
 version  R version 3.6.1 Patched (2019-08-12 r76979)
 os       Windows >= 8 x64                           
 system   x86_64, mingw32                            
 ui       RStudio                                    
 language (EN)                                       
 collate  English_United States.1252                 
 ctype    English_United States.1252                 
 tz       America/Chicago                            
 date     2019-10-29                                 

- Packages --------------------------------------------------------------
 package     * version    date       lib source        
 assertthat    0.2.1      2019-03-21 [1] CRAN (R 3.6.0)
 backports     1.1.5      2019-10-02 [1] CRAN (R 3.6.1)
 bit           1.1-14     2018-05-29 [1] CRAN (R 3.6.0)
 bit64         0.9-7      2017-05-08 [1] CRAN (R 3.6.0)
 blob          1.2.0      2019-07-09 [1] CRAN (R 3.6.1)
 callr         3.3.2      2019-09-22 [1] CRAN (R 3.6.1)
 checkmate     1.9.4      2019-07-04 [1] CRAN (R 3.6.1)
 cli           1.1.0      2019-03-19 [1] CRAN (R 3.6.0)
 colorspace    1.4-1      2019-03-18 [1] CRAN (R 3.6.0)
 config        0.3        2018-03-27 [1] CRAN (R 3.6.0)
 crayon        1.3.4      2017-09-16 [1] CRAN (R 3.6.0)
 DBI           1.0.0      2018-05-02 [1] CRAN (R 3.6.0)
 desc          1.2.0      2018-05-01 [1] CRAN (R 3.6.0)
 devtools      2.2.1      2019-09-24 [1] CRAN (R 3.6.1)
 digest        0.6.22     2019-10-21 [1] CRAN (R 3.6.1)
 dplyr         0.8.3      2019-07-04 [1] CRAN (R 3.6.1)
 ellipsis      0.3.0      2019-09-20 [1] CRAN (R 3.6.1)
 evaluate      0.14       2019-05-28 [1] CRAN (R 3.6.0)
 fs            1.3.1      2019-05-06 [1] CRAN (R 3.6.0)
 ggplot2     * 3.2.1      2019-08-10 [1] CRAN (R 3.6.1)
 glue          1.3.1      2019-03-12 [1] CRAN (R 3.6.0)
 gtable        0.3.0      2019-03-25 [1] CRAN (R 3.6.0)
 highr         0.8        2019-03-20 [1] CRAN (R 3.6.0)
 hms           0.5.1      2019-08-23 [1] CRAN (R 3.6.1)
 htmltools     0.4.0      2019-10-04 [1] CRAN (R 3.6.1)
 knitr       * 1.25       2019-09-18 [1] CRAN (R 3.6.1)
 labeling      0.3        2014-08-23 [1] CRAN (R 3.6.0)
 lattice       0.20-38    2018-11-04 [3] CRAN (R 3.6.1)
 lazyeval      0.2.2      2019-03-15 [1] CRAN (R 3.6.0)
 lifecycle     0.1.0      2019-08-01 [1] CRAN (R 3.6.1)
 lubridate     1.7.4      2018-04-11 [1] CRAN (R 3.6.0)
 magrittr    * 1.5        2014-11-22 [1] CRAN (R 3.6.0)
 memoise       1.1.0      2017-04-21 [1] CRAN (R 3.6.0)
 munsell       0.5.0      2018-06-12 [1] CRAN (R 3.6.0)
 odbc          1.1.6      2018-06-09 [1] CRAN (R 3.6.0)
 OuhscMunge    0.1.9.9010 2019-03-29 [1] local         
 packrat       0.5.0      2018-11-14 [1] CRAN (R 3.6.0)
 pillar        1.4.2      2019-06-29 [1] CRAN (R 3.6.1)
 pkgbuild      1.0.6      2019-10-09 [1] CRAN (R 3.6.1)
 pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 3.6.1)
 pkgload       1.0.2      2018-10-29 [1] CRAN (R 3.6.0)
 prettyunits   1.0.2      2015-07-13 [1] CRAN (R 3.6.0)
 processx      3.4.1      2019-07-18 [1] CRAN (R 3.6.1)
 ps            1.3.0      2018-12-21 [1] CRAN (R 3.6.0)
 purrr         0.3.3      2019-10-18 [1] CRAN (R 3.6.1)
 R6            2.4.0      2019-02-14 [1] CRAN (R 3.6.0)
 Rcpp          1.0.2      2019-07-25 [1] CRAN (R 3.6.1)
 readr         1.3.1      2018-12-21 [1] CRAN (R 3.6.0)
 remotes       2.1.0      2019-06-24 [1] CRAN (R 3.6.1)
 rlang         0.4.1      2019-10-24 [1] CRAN (R 3.6.1)
 rmarkdown     1.16       2019-10-01 [1] CRAN (R 3.6.1)
 rprojroot     1.3-2      2018-01-03 [1] CRAN (R 3.6.0)
 RSQLite       2.1.2      2019-07-24 [1] CRAN (R 3.6.1)
 scales        1.0.0      2018-08-09 [1] CRAN (R 3.6.0)
 sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 3.6.0)
 stringi       1.4.3      2019-03-12 [1] CRAN (R 3.6.0)
 stringr       1.4.0      2019-02-10 [1] CRAN (R 3.6.0)
 testit        0.10       2019-10-01 [1] CRAN (R 3.6.1)
 testthat      2.2.1      2019-07-25 [1] CRAN (R 3.6.1)
 tibble        2.1.3      2019-06-06 [1] CRAN (R 3.6.0)
 tidyr         1.0.0      2019-09-11 [1] CRAN (R 3.6.1)
 tidyselect    0.2.5      2018-10-11 [1] CRAN (R 3.6.0)
 usethis       1.5.1      2019-07-04 [1] CRAN (R 3.6.1)
 vctrs         0.2.0      2019-07-05 [1] CRAN (R 3.6.1)
 viridisLite   0.3.0      2018-02-01 [1] CRAN (R 3.6.0)
 withr         2.1.2      2018-03-15 [1] CRAN (R 3.6.0)
 xfun          0.10       2019-10-01 [1] CRAN (R 3.6.1)
 yaml          2.2.0      2018-07-25 [1] CRAN (R 3.6.0)
 zeallot       0.1.0      2018-01-28 [1] CRAN (R 3.6.0)
 zoo           1.8-6      2019-05-28 [1] CRAN (R 3.6.0)

[1] D:/Projects/RLibraries
[2] D:/Users/Will/Documents/R/win-library/3.6
[3] C:/Program Files/R/R-3.6.1patched/library
```
</details>



Report rendered by Will at 2019-10-29, 13:35 -0500 in 5 seconds.
