



This report was automatically generated with the R package **knitr**
(version 1.10).


```r
# knitr::stitch_rmd(script="./utility/reproduce.R", output="./utility/reproduce.md")

###################################
#'  ---Reproducible Research---
###################################
#' When executed by R, this file will manipulate the original data sources (ie, ZZZZ)
#' to produce a groomed dataset suitable for analysis and graphing.

###################################
#' Clear memory from previous runs
base::rm(list=base::ls(all=TRUE))

###################################
#' Verify the working directory has been set correctly.  Much of the code assumes the working directory is the repository's root directory.
#' In the following line, rename `RAnalysisSkeleton` to your repository.
if( base::basename(base::getwd()) != "RAnalysisSkeleton" ) {
  base::stop("The working directory should be set to the root of the package/repository.  ",
       "It's currently set to `", base::getwd(), "`.")
}
###################################
#' Install the necessary packages.
pathInstallPackages <- "./utility/install_packages.R"
if( !file.exists(pathInstallPackages)) {
  base::stop("The file `", pathInstallPackages, "` was not found.  Make sure the working directory is set to the root of the repository.")
}
base::source(pathInstallPackages, local=new.env())
```

```
## Warning: package 'boot' in library '/usr/lib/R/library' will not be updated
```

```
## Warning: package 'class' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'cluster' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'codetools' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'foreign' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'KernSmooth' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'lattice' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'MASS' in library '/usr/lib/R/library' will not be updated
```

```
## Warning: package 'Matrix' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'mgcv' in library '/usr/lib/R/library' will not be updated
```

```
## Warning: package 'nlme' in library '/usr/lib/R/library' will not be updated
```

```
## Warning: package 'nnet' in library '/usr/lib/R/library' will not be updated
```

```
## Warning: package 'rpart' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'spatial' in library '/usr/lib/R/library' will not be
## updated
```

```
## Warning: package 'survival' in library '/usr/lib/R/library' will not be
## updated
```

```
## Loading required package: classInt
## Loading required package: colorspace
## Loading required package: devtools
## Loading required package: digest
## Loading required package: dplyr
```

```
## Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
## logical.return = TRUE, : there is no package called 'dplyr'
```

```
## Installing package into '/home/wibeasley/R/x86_64-pc-linux-gnu-library/3.2'
## (as 'lib' is unspecified)
## also installing the dependencies 'chron', 'assertthat', 'lazyeval', 'DBI', 'BH', 'RSQLite', 'RMySQL', 'RPostgreSQL', 'data.table', 'microbenchmark', 'Lahman', 'nycflights13'
```

```
## Warning in utils::install.packages(package_name, dependencies = TRUE):
## installation of package 'RMySQL' had non-zero exit status
```

```
## 
## The downloaded source packages are in
## 	'/tmp/Rtmps9W5HP/downloaded_packages'
```

```
## Loading required package: dplyr
## 
## Attaching package: 'dplyr'
## 
## The following object is masked from 'package:stats':
## 
##     filter
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
## 
## Loading required package: evaluate
## Loading required package: foreign
## Loading required package: ggthemes
## Loading required package: googleVis
## 
## Welcome to googleVis version 0.5.8
## 
## Please read the Google API Terms of Use
## before you start using the package:
## https://developers.google.com/terms/
## 
## Note, the plot method of googleVis will by default use
## the standard browser to display its output.
## 
## See the googleVis package vignettes for more details,
## or visit http://github.com/mages/googleVis.
## 
## To suppress this message use:
## suppressPackageStartupMessages(library(googleVis))
## 
## Loading required package: ggmap
## Google Maps API Terms of Service: http://developers.google.com/maps/terms.
## Please cite ggmap if you use it: see citation('ggmap') for details.
## Loading required package: grid
## Loading required package: gridExtra
## Loading required package: knitr
## Loading required package: lme4
## Loading required package: Matrix
## Loading required package: Rcpp
## Loading required package: lubridate
## Loading required package: modeest
## 
## This is package 'modeest' written by P. PONCET.
## For a complete list of functions, use 'library(help = "modeest")' or 'help.start()'.
## 
## Loading required package: plyr
## -------------------------------------------------------------------------
## You have loaded plyr after dplyr - this is likely to cause problems.
## If you need functions from both plyr and dplyr, please load plyr first, then dplyr:
## library(plyr); library(dplyr)
## -------------------------------------------------------------------------
## 
## Attaching package: 'plyr'
## 
## The following object is masked from 'package:lubridate':
## 
##     here
## 
## The following objects are masked from 'package:dplyr':
## 
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
## 
## Loading required package: random
## Loading required package: RColorBrewer
## Loading required package: RCurl
## Loading required package: bitops
## Loading required package: readr
```

```
## Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
## logical.return = TRUE, : there is no package called 'readr'
```

```
## Installing package into '/home/wibeasley/R/x86_64-pc-linux-gnu-library/3.2'
## (as 'lib' is unspecified)
## also installing the dependencies 'htmlwidgets', 'DiagrammeR'
```

```
## 
## The downloaded source packages are in
## 	'/tmp/Rtmps9W5HP/downloaded_packages'
```

```
## Loading required package: readr
## Loading required package: reshape2
## Loading required package: rmarkdown
## Loading required package: RODBC
```

```
## Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
## logical.return = TRUE, : there is no package called 'RODBC'
```

```
## Installing package into '/home/wibeasley/R/x86_64-pc-linux-gnu-library/3.2'
## (as 'lib' is unspecified)
```

```
## Warning in utils::install.packages(package_name, dependencies = TRUE):
## installation of package 'RODBC' had non-zero exit status
```

```
## 
## The downloaded source packages are in
## 	'/tmp/Rtmps9W5HP/downloaded_packages'
```

```
## Loading required package: RODBC
```

```
## Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
## logical.return = TRUE, : there is no package called 'RODBC'
```

```
## Loading required package: roxygen2
## Loading required package: stringr
## Loading required package: testit
## Loading required package: testthat
## Loading required package: xtable
## Loading required package: yaml
## Loading required package: zipcode
```

```
## Warning: This Linux machine is possibly missing the 'libcurl' library.
## Consider running `sudo apt-get install libcurl4-openssl-dev`.
```

```
## '/usr/lib/R/bin/R' --vanilla CMD SHLIB foo.c 
## 
## Downloading devtools from https://github.com/hadley/devtools/archive/master.zip
## '/usr/lib/R/bin/R' --vanilla CMD INSTALL  \
##   '/tmp/Rtmps9W5HP/devtools-master' --build
```

```
## Error: Command failed (1)
```

```r
base::rm(pathInstallPackages)
###################################
#' Load the necessary packages.
base::library(base)
base::library(knitr)
base::library(markdown)
base::library(testit)

######################################################################################################
#' The following example comes from https://github.com/wibeasley/Wats.  Rename the paths appropriately.
#'
#'
###################################
#' Declare the paths of the necessary files.

#' The raw/input data files:
# pathCensus199x <- base::paste0("./Datasets/CensusIntercensal/STCH-icen199", 0:9, ".txt")
# pathCensus200x <- "./Datasets/CensusIntercensal/CO-EST00INT-AGESEX-5YR.csv"
# pathCountyFips <- "./Datasets/CountyFipsCode.csv"

#' The derived/intermediate data files (which are produced by the repository's code files):
# pathCensusYearly <- "./Datasets/CensusIntercensal/CensusCountyYear.csv"
# pathCensusMonthly <- "./Datasets/CensusIntercensal/CensusCountyMonth.csv"
# pathDataForAnalaysis2005 <- "./Datasets/CountyMonthBirthRate2005Version.csv"
# pathDataForAnalaysis2014 <- "./Datasets/CountyMonthBirthRate2014Version.csv"

#' Code Files:
# pathManipulateCensus <- "./UtilityScripts/IsolateCensusPopsForGfr.R"
# pathCalculateGfr <- "./UtilityScripts/CalculateGfr.R"

#' Report Files:
# pathsReports <- base::file.path("./vignettes", c("MbrFigures.Rmd", "OkFertilityWithIntercensalEstimates.Rmd"))

###################################
#' Verify the necessary path can be found.

#' The raw/input data files:
# testit::assert("The 10 census files from 199x should exist.", base::file.exists(pathCensus199x))
# testit::assert("The 200x census file should exist.", base::file.exists(pathCensus200x))
# testit::assert("The county FIPS values should exist.", base::file.exists(pathCountyFips))

#' Code Files:
# testit::assert("The file that restructures the census data should exist.", base::file.exists(pathManipulateCensus))
# testit::assert("The file that calculates the GFR should exist.", base::file.exists(pathCalculateGfr))

#' Report Files:
# testit::assert("The knitr Rmd files should exist.", base::file.exists(pathsReports))

####################################
#' Run the files that manipulate and analyze.

#' Execute code that restructures the Census data
# base::source(pathManipulateCensus, local=base::new.env())

#' Assert that the intermediate files exist (the two files produced by `IsolateCensusPopsForGfr.R`)
# testit::assert("The yearly records should exist.", base::file.exists(pathCensusYearly))
# testit::assert("The monthly records should exist.", base::file.exists(pathCensusMonthly))

#' Execute code that combines the census and birth count data.
# base::source(pathCalculateGfr, local=base::new.env())

#' Verify that the two human readable datasets are present.
# testit::assert("The CSV for the 2005 Version should exist.", base::file.exists(pathDataForAnalaysis2005))
# testit::assert("The CSV for the 2014 Version should exist.", base::file.exists(pathDataForAnalaysis2014))

####################################
#' Build the reports
# for( pathRmd in pathsReports ) {
#   pathMd <- base::gsub(pattern=".Rmd$", replacement=".md", x=pathRmd)
#   pathHtml <- base::gsub(pattern=".Rmd$", replacement=".html", x=pathRmd)
#   knitr::knit(input=pathRmd, output=pathMd)
#   markdown::markdownToHTML(file=pathMd, output=pathHtml)
# }
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.2.0 (2015-04-16)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 14.04.2 LTS
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
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
##  [1] markdown_0.7.7     zipcode_1.0        yaml_2.1.13       
##  [4] xtable_1.7-4       testthat_0.9.1     testit_0.4        
##  [7] stringr_1.0.0      roxygen2_4.1.1     rmarkdown_0.5.3.1 
## [10] reshape2_1.4.1     readr_0.1.0        RCurl_1.95-4.6    
## [13] bitops_1.0-6       RColorBrewer_1.1-2 random_0.2.3      
## [16] plyr_1.8.2         modeest_2.1        lubridate_1.3.3   
## [19] lme4_1.1-7         Rcpp_0.11.6        Matrix_1.2-0      
## [22] knitr_1.10         gridExtra_0.9.1    ggmap_2.4         
## [25] googleVis_0.5.8    ggthemes_2.1.2     foreign_0.8-63    
## [28] evaluate_0.7       dplyr_0.4.1        digest_0.6.8      
## [31] devtools_1.7.0     colorspace_1.2-6   classInt_0.1-22   
## [34] ggplot2_1.0.1     
## 
## loaded via a namespace (and not attached):
##  [1] splines_3.2.0       lattice_0.20-31     htmltools_0.2.6    
##  [4] e1071_1.6-4         nloptr_1.0.4        DBI_0.3.1          
##  [7] sp_1.1-0            jpeg_0.1-8          munsell_0.4.2      
## [10] gtable_0.1.2        RgoogleMaps_1.2.0.7 mapproj_1.2-2      
## [13] memoise_0.2.1       labeling_0.3        parallel_3.2.0     
## [16] curl_0.5            class_7.3-12        proto_0.3-10       
## [19] geosphere_1.3-13    scales_0.2.4        formatR_1.2        
## [22] rjson_0.2.15        png_0.1-7           stringi_0.4-1      
## [25] RJSONIO_1.3-0       tools_3.2.0         magrittr_1.5       
## [28] maps_2.3-9          MASS_7.3-40         httr_0.6.1         
## [31] assertthat_0.1      minqa_1.2.4         nlme_3.1-120
```

```r
Sys.time()
```

```
## [1] "2015-05-02 12:06:41 CDT"
```

