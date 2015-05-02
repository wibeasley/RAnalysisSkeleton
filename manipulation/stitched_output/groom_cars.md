



This report was automatically generated with the R package **knitr**
(version 1.10).


```r
# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
```

```r
############################
```

```r
# library(plyr)
library(ggplot2)

############################
```

```r
pathInput <- "./data_phi_free/raw/mtcars_dataset.csv"
pathOutput <- "./data_phi_free/derived/motor_trend_car_test.rds"

prematureThresholdInWeeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeksPerYear <- 365.25/7
daysPerWeek <- 7

############################
```

```r
ds <- read.csv(pathInput, stringsAsFactors=FALSE)
colnames(ds)
```

```
##  [1] "model" "mpg"   "cyl"   "disp"  "hp"    "drat"  "wt"    "qsec" 
##  [9] "vs"    "am"    "gear"  "carb"
```

```r
# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
ds <- plyr::rename(ds, replace=c(
  "model" = "ModelName"
  , "mpg" = "MilesPerGallon"
  , "cyl" = "CylinderCount"
  , "disp" = "DisplacementInchesCubed"
  , "hp" = "GrossHorsepower"
  , "drat" = "RearAxleRatio"
  , "wt" = "WeightInPoundsPer1000"
  , "qsec" = "QuarterMileInSeconds"
  , "vs" = "VS" #TODO: need a definition for this variable
  , "am" = "AutomaticTransmission"
  , "gear" = "ForwardGearCount"
  , "carb" = "CarburetorCount"
))
############################
```

```r
# Add a unique identifier
ds$CarID <- seq_len(nrow(ds))

# Clear up confusion about units and remove old variable
ds$WeightInPounds <- ds$WeightInPoundsPer1000 * 1000
ds$WeightInPoundsPer1000 <- NULL

# Convert some to boolean variables
ds$VS <- as.logical(ds$VS)
ds$AutomaticTransmission <- as.logical(ds$AutomaticTransmission)

# Create duplicates of variables as factors (not numbers), which can help with later graphs or analyses.
#   Admittedly, the labels are a contrived example of a factor, but helps the example later.
ds$ForwardGearCountF <- factor(ds$ForwardGearCount, levels=3:5, labels=c("Three", "Four", "Five"))
ds$CarburetorCountF <- factor(ds$CarburetorCount)

### Create transformations and interactions to help later graphs and models.
ds$DisplacementInchesCubedLog10 <- log10(ds$DisplacementInchesCubed)
ds$GrossHorsepowerByGearCount3 <- ds$GrossHorsepower * (ds$ForwardGearCount=="Three")
ds$GrossHorsepowerByGearCount4 <- ds$GrossHorsepower * (ds$ForwardGearCount=="Four")

############################
```

```r
# I'm pretending the dataset had unreasonably low values that were artifacts of the measurement equipment.
ds$MilesPerGallonArtifact <- (ds$MilesPerGallon < 2.2)
ds$MilesPerGallon <- ifelse(ds$MilesPerGallonArtifact, NA_real_, ds$MilesPerGallon)

############################
```

```r
# This creates z-scores WITHIN ForwardGearCount levels
ds <- plyr::ddply(ds, .variables="ForwardGearCountF", .fun=transform,
                  DisplacementInchesCubedZ=scale(DisplacementInchesCubed),
                  WeightInPoundsZ=scale(WeightInPounds)
                  )
# Quick inspection of the distribution of z scores within levels
ggplot2::qplot(ds$WeightInPoundsZ, color=ds$ForwardGearCountF, geom="density")  # mean(ds$WeightInPoundsZ, na.rm=T)
```

<img src="figure/groom-cars-Rmdcreate_z_scores-1.png" title="plot of chunk create_z_scores" alt="plot of chunk create_z_scores" style="display: block; margin: auto;" />

```r
# Create a boolean variable, indicating if the z scores is above a certain threshold.
ds$WeightInPoundsZAbove1 <- (ds$WeightInPoundsZ > 1.00)
############################
```

```r
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
saveRDS(ds, file=pathOutput, compress="xz")
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
## [1] "2015-05-02 12:11:08 CDT"
```

