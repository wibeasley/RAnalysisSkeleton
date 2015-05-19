



This report was automatically generated with the R package **knitr**
(version 1.10.5).


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
requireNamespace(plyr, quietly=TRUE)
```

```
## Error in requireNamespace(plyr, quietly = TRUE): object 'plyr' not found
```

```r
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
## R version 3.2.0 Patched (2015-05-11 r68355)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
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
## [1] ggplot2_1.0.1
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6      digest_0.6.8     MASS_7.3-40      grid_3.2.0      
##  [5] plyr_1.8.2       gtable_0.1.2     formatR_1.2      magrittr_1.5    
##  [9] evaluate_0.7     scales_0.2.4     stringi_0.4-1    reshape2_1.4.1  
## [13] labeling_0.3     proto_0.3-10     tools_3.2.0      stringr_1.0.0   
## [17] munsell_0.4.2    colorspace_1.2-6 knitr_1.10.5
```

```r
Sys.time()
```

```
## [1] "2015-05-19 14:51:30 CDT"
```

