---
title: Skeleton Report 1
date: "Date: 2018-09-28"
output:
  # radix::radix_article: # radix is a newer alternative that has some advantages over `html_document`.
  html_document:
    keep_md: yes
    toc: 4
    toc_float: true
    number_sections: true
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

![](figure-png/scatterplots-1.png)<!-- -->![](figure-png/scatterplots-2.png)<!-- -->![](figure-png/scatterplots-3.png)<!-- -->


Models
===========================================================================

Model Exploration
---------------------------------------------------------------------------

```
============= Simple model that's just an intercept. =============
```

```

Call:
lm(formula = quarter_mile_in_seconds ~ 1, data = ds)

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
lm(formula = quarter_mile_in_seconds ~ 1 + miles_per_gallon, 
    data = ds)

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

Model 1: quarter_mile_in_seconds ~ 1
Model 2: quarter_mile_in_seconds ~ 1 + miles_per_gallon
  Res.Df    RSS Df Sum of Sq      F  Pr(>F)
1     31 98.988                            
2     30 81.636  1    17.352 6.3767 0.01708
```

```
============= Model includes two predictors. =============
```

```

Call:
lm(formula = quarter_mile_in_seconds ~ 1 + miles_per_gallon + 
    forward_gear_count_f, data = ds)

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

Model 1: quarter_mile_in_seconds ~ 1 + miles_per_gallon
Model 2: quarter_mile_in_seconds ~ 1 + miles_per_gallon + forward_gear_count_f
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


Session Information
===========================================================================

For the sake of documentation and reproducibility, the current report was rendered in the following environment.  Click the line below to expand.

<details>
  <summary>Environment <span class="glyphicon glyphicon-plus-sign"></span></summary>

```
Session info --------------------------------------------------------------------------------------
```

```
 setting  value                                      
 version  R version 3.5.1 Patched (2018-09-10 r75281)
 system   x86_64, mingw32                            
 ui       RTerm                                      
 language (EN)                                       
 collate  English_United States.1252                 
 tz       America/Chicago                            
 date     2018-09-28                                 
```

```
Packages ------------------------------------------------------------------------------------------
```

```
 package     * version    date       source                          
 assertthat    0.2.0      2017-04-11 CRAN (R 3.5.0)                  
 backports     1.1.2      2017-12-13 CRAN (R 3.5.0)                  
 base        * 3.5.1      2018-09-11 local                           
 bindr         0.1.1      2018-03-13 CRAN (R 3.5.0)                  
 bindrcpp    * 0.2.2      2018-03-29 CRAN (R 3.5.0)                  
 colorspace    1.3-2      2016-12-14 CRAN (R 3.5.0)                  
 compiler      3.5.1      2018-09-11 local                           
 crayon        1.3.4      2017-09-16 CRAN (R 3.5.0)                  
 datasets    * 3.5.1      2018-09-11 local                           
 devtools      1.13.6     2018-06-27 CRAN (R 3.5.0)                  
 digest        0.6.17     2018-09-12 CRAN (R 3.5.1)                  
 dplyr         0.7.6      2018-06-29 CRAN (R 3.5.1)                  
 evaluate      0.11       2018-07-17 CRAN (R 3.5.1)                  
 ggplot2     * 3.0.0      2018-07-03 CRAN (R 3.5.1)                  
 glue          1.3.0      2018-07-17 CRAN (R 3.5.1)                  
 graphics    * 3.5.1      2018-09-11 local                           
 grDevices   * 3.5.1      2018-09-11 local                           
 grid          3.5.1      2018-09-11 local                           
 gtable        0.2.0      2016-02-26 CRAN (R 3.5.0)                  
 highr         0.7        2018-06-09 CRAN (R 3.5.0)                  
 hms           0.4.2.9001 2018-08-09 Github (tidyverse/hms@979286f)  
 htmltools     0.3.6      2017-04-28 CRAN (R 3.5.0)                  
 knitr       * 1.20       2018-02-20 CRAN (R 3.5.0)                  
 labeling      0.3        2014-08-23 CRAN (R 3.5.0)                  
 lazyeval      0.2.1      2017-10-29 CRAN (R 3.5.0)                  
 magrittr    * 1.5        2014-11-22 CRAN (R 3.5.0)                  
 memoise       1.1.0      2017-04-21 CRAN (R 3.5.0)                  
 methods     * 3.5.1      2018-09-11 local                           
 munsell       0.5.0      2018-06-12 CRAN (R 3.5.0)                  
 pillar        1.3.0      2018-07-14 CRAN (R 3.5.1)                  
 pkgconfig     2.0.2      2018-08-16 CRAN (R 3.5.1)                  
 plyr          1.8.4      2016-06-08 CRAN (R 3.5.0)                  
 purrr         0.2.5      2018-05-29 CRAN (R 3.5.0)                  
 R6            2.2.2      2017-06-17 CRAN (R 3.5.0)                  
 Rcpp          0.12.18    2018-07-23 CRAN (R 3.5.1)                  
 readr         1.2.0      2018-08-09 Github (tidyverse/readr@4b2e93a)
 rlang         0.2.2      2018-08-16 CRAN (R 3.5.1)                  
 rmarkdown     1.10       2018-06-11 CRAN (R 3.5.0)                  
 rprojroot     1.3-2      2018-01-03 CRAN (R 3.5.0)                  
 scales        1.0.0      2018-08-09 CRAN (R 3.5.1)                  
 stats       * 3.5.1      2018-09-11 local                           
 stringi       1.2.4      2018-07-20 CRAN (R 3.5.1)                  
 stringr       1.3.1      2018-05-10 CRAN (R 3.5.0)                  
 tibble        1.4.2      2018-01-22 CRAN (R 3.5.0)                  
 tidyselect    0.2.4      2018-02-26 CRAN (R 3.5.0)                  
 tools         3.5.1      2018-09-11 local                           
 utils       * 3.5.1      2018-09-11 local                           
 viridisLite   0.3.0      2018-02-01 CRAN (R 3.5.0)                  
 withr         2.1.2      2018-03-15 CRAN (R 3.5.0)                  
 yaml          2.2.0      2018-07-25 CRAN (R 3.5.1)                  
```
</details>



Report rendered by Will at 2018-09-28, 16:18 -0500 in 4 seconds.
