



This report was automatically generated with the R package **knitr**
(version 1.11).


```r
# knitr::stitch_rmd(script="./utility/reproduce.R", output="./utility/reproduce.md")

# Reproducible Research ---------------------------------------------------
#' When executed by R, this file will manipulate the original data sources (ie, ZZZZ)
#' to produce a groomed dataset suitable for analysis and graphing.

# Clear memory from previous runs -----------------------------------------
base::rm(list=base::ls(all=TRUE))

# Check Working Directory -------------------------------------------------
#' Verify the working directory has been set correctly.  Much of the code assumes the working directory is the repository's root directory.
#' In the following line, rename `RAnalysisSkeleton` to your repository.
if( base::basename(base::getwd()) != "RAnalysisSkeleton" ) {
  base::stop("The working directory should be set to the root of the package/repository.  ",
       "It's currently set to `", base::getwd(), "`.")
}

# Install the necessary packages ------------------------------------------
path_install_packages <- "./utility/install_packages.R"
if( !file.exists(path_install_packages)) {
  base::stop("The file `", path_install_packages, "` was not found.  Make sure the working directory is set to the root of the repository.")
}
base::source(path_install_packages, local=new.env())
```

```
## Downloading GitHub repo OuhscBbmc/OuhscMunge@master
## Installing OuhscMunge
## "C:/PROGRA~1/R/R-32~1.2PA/bin/x64/R" --no-site-file --no-environ  \
##   --no-save --no-restore CMD INSTALL  \
##   "C:/Users/Will/AppData/Local/Temp/RtmpC0BA90/devtools2be013fc77fc/OuhscBbmc-OuhscMunge-99b5960"  \
##   --library="D:/Users/Will/Documents/R/win-library/3.2" --install-tests 
## 
## package_janitor is loading the list of package depencies.
## package_janitor is updating the existing packages from CRAN.
```

```
## Warning: package 'MASS' in library 'C:/Program Files/R/R-3.2.2patched/
## library' will not be updated
```

```
## Warning: package 'Matrix' in library 'C:/Program Files/R/R-3.2.2patched/
## library' will not be updated
```

```
## Warning: package 'mgcv' in library 'C:/Program Files/R/R-3.2.2patched/
## library' will not be updated
```

```
## package_janitor is installing the the `devtools` and `httr` packages from CRAN if necessary.
## package_janitor is installing the CRAN packages:
## `classInt` exists, and verifying it's dependencies are installed too.
## `colorspace` exists, and verifying it's dependencies are installed too.
## The `devtools` package does not need to be in the list of package dependencies.  It's updated automatically.
## `digest` exists, and verifying it's dependencies are installed too.
## `dplyr` exists, and verifying it's dependencies are installed too.
## Skipping 2 packages ahead of CRAN: DBI, RSQLite
## `evaluate` exists, and verifying it's dependencies are installed too.
## `ggplot2` exists, and verifying it's dependencies are installed too.
## `ggthemes` exists, and verifying it's dependencies are installed too.
## `googleVis` exists, and verifying it's dependencies are installed too.
## `ggmap` exists, and verifying it's dependencies are installed too.
## Skipping 1 packages ahead of CRAN: DBI
## `grid` exists, and verifying it's dependencies are installed too.
## `gridExtra` exists, and verifying it's dependencies are installed too.
## `knitr` exists, and verifying it's dependencies are installed too.
## `lubridate` exists, and verifying it's dependencies are installed too.
## `modeest` exists, and verifying it's dependencies are installed too.
## `plyr` exists, and verifying it's dependencies are installed too.
## `random` exists, and verifying it's dependencies are installed too.
## `RColorBrewer` exists, and verifying it's dependencies are installed too.
## `readr` exists, and verifying it's dependencies are installed too.
## `reshape2` exists, and verifying it's dependencies are installed too.
## `rmarkdown` exists, and verifying it's dependencies are installed too.
## `stringi` exists, and verifying it's dependencies are installed too.
## `stringr` exists, and verifying it's dependencies are installed too.
## `testit` exists, and verifying it's dependencies are installed too.
## `testthat` exists, and verifying it's dependencies are installed too.
## `tidyr` exists, and verifying it's dependencies are installed too.
## Skipping 1 packages ahead of CRAN: DBI
```

```
## Error in install_packages(behind, repos = attr(object, "repos"), type = attr(object, : formal argument "repos" matched by multiple actual arguments
```

```r
base::rm(path_install_packages)

# Load the necessary packages ---------------------------------------------
base::requireNamespace("base", quietly=T)
base::requireNamespace("knitr", quietly=T)
base::requireNamespace("markdown", quietly=T)
base::requireNamespace("testit", quietly=T)

######################################################################################################
#' The following example comes from https://github.com/wibeasley/Wats.  Rename the paths appropriately.

# Declare the paths of the necessary files --------------------------------

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

# Verify the necessary path can be found ----------------------------------

#' The raw/input data files:
# testit::assert("The 10 census files from 199x should exist.", base::file.exists(pathCensus199x))
# testit::assert("The 200x census file should exist.", base::file.exists(pathCensus200x))
# testit::assert("The county FIPS values should exist.", base::file.exists(pathCountyFips))

#' Code Files:
# testit::assert("The file that restructures the census data should exist.", base::file.exists(pathManipulateCensus))
# testit::assert("The file that calculates the GFR should exist.", base::file.exists(pathCalculateGfr))

# Report Files:
# testit::assert("The knitr Rmd files should exist.", base::file.exists(pathsReports))

# Run the files that manipulate and analyze -------------------------------

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

# Build the reports -------------------------------------------------------
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
## R version 3.2.2 Patched (2015-10-11 r69514)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows >= 8 x64 (build 9200)
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
## [1] magrittr_1.5  ggplot2_1.0.1
## 
## loaded via a namespace (and not attached):
##  [1] reshape2_1.4.1      ggthemes_2.2.1      lattice_0.20-33    
##  [4] testthat_0.11.0     colorspace_1.2-6    htmltools_0.2.6    
##  [7] yaml_2.1.13         e1071_1.6-7         DBI_0.3.1.9008     
## [10] sp_1.2-1            RColorBrewer_1.1-2  jpeg_0.1-8         
## [13] plyr_1.8.3          stringr_1.0.0       munsell_0.4.2      
## [16] gtable_0.1.2        devtools_1.9.1      RgoogleMaps_1.2.0.7
## [19] mapproj_1.2-4       memoise_0.2.1       evaluate_0.8       
## [22] labeling_0.3        knitr_1.11          modeest_2.1        
## [25] OuhscMunge_0.1.5    parallel_3.2.2      curl_0.9.4         
## [28] class_7.3-14        markdown_0.7.7      proto_0.3-10       
## [31] Rcpp_0.12.2         geosphere_1.4-3     readr_0.2.2        
## [34] scales_0.3.0        classInt_0.1-23     formatR_1.2.1      
## [37] googleVis_0.5.10    gridExtra_2.0.0     testit_0.4         
## [40] rjson_0.2.15        png_0.1-7           digest_0.6.8       
## [43] stringi_1.0-1       dplyr_0.4.3         RJSONIO_1.3-0      
## [46] grid_3.2.2          tools_3.2.2         maps_3.0.0-2       
## [49] lazyeval_0.1.10     tidyr_0.3.1         crayon_1.3.1       
## [52] MASS_7.3-44         rsconnect_0.3.79    random_0.2.5       
## [55] lubridate_1.3.3     assertthat_0.1      rmarkdown_0.8.1    
## [58] httr_1.0.0          R6_2.1.1            ggmap_2.5.2
```

```r
Sys.time()
```

```
## [1] "2015-11-30 09:56:00 CST"
```

