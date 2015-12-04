



This report was automatically generated with the R package **knitr**
(version 1.11.3).


```r
# knitr::stitch_rmd(script="./manipulation/car-ellis.R", output="./manipulation/stitched-output/car-ellis.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
```

```r
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
```

```r
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2)
library(magrittr) #Pipes

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("dplyr", quietly=TRUE) #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit", quietly=TRUE)
# requireNamespace("plyr", quietly=TRUE)
```

```r
path_input  <- "./data-phi-free/raw/mtcar.csv"
path_output <- "./data-phi-free/derived/motor-trend-car-test.rds"

premature_threshold_in_weeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeks_per_year <- 365.25/7
days_per_week <- 7
```

```r
ds <- read.csv(path_input, stringsAsFactors=FALSE)
```

```r
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

<img src="figure/car-ellis-Rmdcreate_z_scores-1.png" title="plot of chunk create_z_scores" alt="plot of chunk create_z_scores" style="display: block; margin: auto;" />

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
saveRDS(ds, file=path_output, compress="xz")
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.2.2 (2015-08-14)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 14.04.3 LTS
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
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] magrittr_1.5  ggplot2_1.0.1
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.2        digest_0.6.8       dplyr_0.4.3.9000  
##  [4] assertthat_0.1     MASS_7.3-45        plyr_1.8.3        
##  [7] grid_3.2.2         R6_2.1.1           gtable_0.1.2      
## [10] DBI_0.3.1.9008     formatR_1.2.1      scales_0.3.0      
## [13] evaluate_0.8       stringi_1.0-1      lazyeval_0.1.10   
## [16] reshape2_1.4.1     testit_0.4         labeling_0.3      
## [19] proto_0.3-10       tools_3.2.2        stringr_1.0.0.9000
## [22] munsell_0.4.2      parallel_3.2.2     colorspace_1.2-6  
## [25] knitr_1.11.3
```

```r
Sys.time()
```

```
## [1] "2015-12-03 22:21:20 CST"
```

