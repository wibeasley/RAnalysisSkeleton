---
title: Skeleton Report 1
date: "Date: 2019-12-16"
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
─ Session info ───────────────────────────────────────────────────────────
 setting  value                       
 version  R version 3.6.1 (2019-07-05)
 os       Ubuntu 19.10                
 system   x86_64, linux-gnu           
 ui       RStudio                     
 language (EN)                        
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       America/Chicago             
 date     2019-12-16                  

─ Packages ───────────────────────────────────────────────────────────────
 package     * version    date       lib
 assertthat    0.2.1      2019-03-21 [1]
 backports     1.1.5      2019-10-02 [1]
 bit           1.1-14     2018-05-29 [1]
 bit64         0.9-7      2017-05-08 [1]
 blob          1.2.0      2019-07-09 [1]
 callr         3.4.0      2019-12-09 [1]
 checkmate     2.0.0      2019-12-03 [1]
 cli           2.0.0      2019-12-09 [1]
 colorspace    1.4-1      2019-03-18 [1]
 config        0.3        2018-03-27 [1]
 crayon        1.3.4      2017-09-16 [1]
 DBI           1.0.0      2018-05-02 [1]
 desc          1.2.0      2018-05-01 [1]
 devtools      2.2.1      2019-09-24 [1]
 digest        0.6.23     2019-11-23 [1]
 dplyr         0.8.3      2019-07-04 [1]
 ellipsis      0.3.0      2019-09-20 [1]
 evaluate      0.14       2019-05-28 [1]
 fansi         0.4.0      2018-10-05 [1]
 farver        2.0.1      2019-11-13 [1]
 fs            1.3.1      2019-05-06 [1]
 ggplot2     * 3.2.1      2019-08-10 [1]
 glue          1.3.1      2019-03-12 [1]
 gtable        0.3.0      2019-03-25 [1]
 highr         0.8        2019-03-20 [1]
 hms           0.5.2      2019-10-30 [1]
 htmltools     0.4.0      2019-10-04 [1]
 import        1.1.0      2015-06-22 [1]
 knitr       * 1.26       2019-11-12 [1]
 labeling      0.3        2014-08-23 [1]
 lattice       0.20-38    2018-11-04 [1]
 lazyeval      0.2.2      2019-03-15 [1]
 lifecycle     0.1.0      2019-08-01 [1]
 lubridate     1.7.4      2018-04-11 [1]
 magrittr      1.5        2014-11-22 [1]
 memoise       1.1.0      2017-04-21 [1]
 munsell       0.5.0      2018-06-12 [1]
 odbc          1.2.1      2019-12-05 [1]
 OuhscMunge    0.1.9.9010 2019-11-16 [1]
 packrat       0.5.0      2018-11-14 [1]
 pillar        1.4.2      2019-06-29 [1]
 pkgbuild      1.0.6      2019-10-09 [1]
 pkgconfig     2.0.3      2019-09-22 [1]
 pkgload       1.0.2      2018-10-29 [1]
 prettyunits   1.0.2      2015-07-13 [1]
 processx      3.4.1      2019-07-18 [1]
 ps            1.3.0      2018-12-21 [1]
 purrr         0.3.3      2019-10-18 [1]
 R6            2.4.1      2019-11-12 [1]
 Rcpp          1.0.3      2019-11-08 [1]
 readr         1.3.1      2018-12-21 [1]
 remotes       2.1.0      2019-06-24 [1]
 rlang         0.4.2      2019-11-23 [1]
 rmarkdown     1.18       2019-11-27 [1]
 rprojroot     1.3-2      2018-01-03 [1]
 RSQLite       2.1.4      2019-12-04 [1]
 scales        1.1.0      2019-11-18 [1]
 sessioninfo   1.1.1      2018-11-05 [1]
 stringi       1.4.3      2019-03-12 [1]
 stringr       1.4.0      2019-02-10 [1]
 testit        0.11       2019-11-12 [1]
 testthat      2.3.1      2019-12-01 [1]
 tibble        2.1.3      2019-06-06 [1]
 tidyr         1.0.0      2019-09-11 [1]
 tidyselect    0.2.5      2018-10-11 [1]
 usethis       1.5.1      2019-07-04 [1]
 vctrs         0.2.0      2019-07-05 [1]
 viridisLite   0.3.0      2018-02-01 [1]
 withr         2.1.2      2018-03-15 [1]
 xfun          0.11       2019-11-12 [1]
 yaml          2.2.0      2018-07-25 [1]
 zeallot       0.1.0      2018-01-28 [1]
 zoo           1.8-6      2019-05-28 [1]
 source                               
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 local                                
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 Github (OuhscBbmc/OuhscMunge@015124a)
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       
 CRAN (R 3.6.1)                       

[1] /home/wibeasley/R/x86_64-pc-linux-gnu-library/3.6
[2] /usr/local/lib/R/site-library
[3] /usr/lib/R/site-library
[4] /usr/lib/R/library
```
</details>



Report rendered by wibeasley at 2019-12-16, 11:53 -0600 in 7 seconds.
