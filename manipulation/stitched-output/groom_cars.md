



This report was automatically generated with the R package **knitr**
(version 1.11).


```r
# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched-output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
```


```r
library(ggplot2)
library(magrittr) #Pipes
requireNamespace("dplyr", quietly=TRUE)
# requireNamespace("plyr", quietly=TRUE)
requireNamespace("testit", quietly=TRUE)
```

```r
pathInput <- "./data-phi-free/raw/mtcars-dataset.csv"
pathOutput <- "./data-phi-free/derived/motor-trend-car-test.rds"

prematureThresholdInWeeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeksPerYear <- 365.25/7
daysPerWeek <- 7
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
ds <- dplyr::rename_(ds,
  "ModelName"                 = "model"
  , "MilesPerGallon"          = "mpg"
  , "CylinderCount"           = "cyl"
  , "DisplacementInchesCubed" = "disp"
  , "GrossHorsepower"         = "hp"
  , "RearAxleRatio"           = "drat"
  , "WeightInPoundsPer1000"   = "wt"
  , "QuarterMileInSeconds"    = "qsec"
  , "VS"                      = "vs" #TODO: need a definition for this variable
  , "AutomaticTransmission"   = "am"
  , "ForwardGearCount"        = "gear"
  , "CarburetorCount"         = "carb"
)
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
```

```r
# I'm pretending the dataset had unreasonably low values that were artifacts of the measurement equipment.
ds$MilesPerGallonArtifact <- (ds$MilesPerGallon < 2.2)
ds$MilesPerGallon <- ifelse(ds$MilesPerGallonArtifact, NA_real_, ds$MilesPerGallon)
```

```r
# This creates z-scores WITHIN ForwardGearCount levels
ds <- ds %>%
  dplyr::group_by(ForwardGearCount) %>%
  dplyr::mutate(
    DisplacementGearZ = as.numeric(base::scale(DisplacementInchesCubed)),
    WeightGearZ       = as.numeric(base::scale(WeightInPounds))
  )

  # ds <- plyr::ddply(ds, .variables="ForwardGearCountF", .fun=transform,
  #                   DisplacementGearZ=scale(DisplacementInchesCubed),
  #                   WeightGearZ=scale(WeightInPounds)
  #                   )

# Quick inspection of the distribution of z scores within levels
ggplot2::qplot(ds$WeightGearZ, color=ds$ForwardGearCountF, geom="density")  # mean(ds$WeightGearZ, na.rm=T)
```

<img src="figure/groom-cars-Rmdcreate_z_scores-1.png" title="plot of chunk create_z_scores" alt="plot of chunk create_z_scores" style="display: block; margin: auto;" />

```r
# Create a boolean variable, indicating if the z scores is above a certain threshold.
ds$WeightGearZAbove1 <- (ds$WeightGearZ > 1.00)
```

```r
testit::assert("`ModelName` should be a unique value", sum(duplicated(ds$ModelName))==0L)
testit::assert("`MilesPerGallon` should be a positive value.", all(ds$MilesPerGallon>0))
testit::assert("`WeightGearZ` should be a positive or missing value.", all(is.na(ds$MilesPerGallon) | (ds$MilesPerGallon>0)))
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
## R version 3.2.2 Patched (2015-09-18 r69405)
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
## [1] ggplot2_1.0.1 magrittr_1.5 
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.1      digest_0.6.8     dplyr_0.4.3      assertthat_0.1  
##  [5] MASS_7.3-44      grid_3.2.2       R6_2.1.1         plyr_1.8.3      
##  [9] gtable_0.1.2     DBI_0.3.1        formatR_1.2.1    evaluate_0.8    
## [13] scales_0.3.0     stringi_0.5-5    reshape2_1.4.1   lazyeval_0.1.10 
## [17] testit_0.4       labeling_0.3     proto_0.3-10     tools_3.2.2     
## [21] stringr_1.0.0    munsell_0.4.2    parallel_3.2.2   colorspace_1.2-6
## [25] knitr_1.11
```

```r
Sys.time()
```

```
## [1] "2015-10-09 13:36:54 CDT"
```

