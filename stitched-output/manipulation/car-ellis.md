



This report was automatically generated with the R package **knitr**
(version 1.15.1).


```r
# knitr::stitch_rmd(script="./manipulation/car-ellis.R", output="./stitched-output/manipulation/car-ellis.md")
# These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
```

```r
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
```

```r
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr             , quietly=TRUE) #Pipes

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2"                 )
requireNamespace("readr"                   )
requireNamespace("tidyr"                   )
requireNamespace("dplyr"                   ) #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"                  ) #For asserting conditions meet expected patterns.
```

```r
path_input  <- "./data-public/raw/mtcar.csv"
path_output <- "./data-public/derived/motor-trend-car-test.rds"
figure_path <- 'stitched-output/manipulation/car/'

premature_threshold_in_weeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeks_per_year <- 365.25/7
days_per_week <- 7
```

```r
ds <- readr::read_csv(path_input)
```

```
## Parsed with column specification:
## cols(
##   model = col_character(),
##   mpg = col_double(),
##   cyl = col_integer(),
##   disp = col_double(),
##   hp = col_integer(),
##   drat = col_double(),
##   wt = col_double(),
##   qsec = col_double(),
##   vs = col_integer(),
##   am = col_integer(),
##   gear = col_integer(),
##   carb = col_integer()
## )
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
# Populate the rename entries with OuhscMunge::column_rename_headstart(ds_county) # devtools::install_github("OuhscBbmc/OuhscMunge")
ds <- dplyr::rename_(ds,
  "model_name"                    = "model"
  , "miles_per_gallon"            = "mpg"
  , "cylinder_count"              = "cyl"
  , "displacement_inches_cubed"   = "disp"
  , "gross_horsepower"            = "hp"
  , "rear_axle_ratio"             = "drat"
  , "weight_in_pounds_per_1000"   = "wt"
  , "quarter_mile_in_seconds"     = "qsec"
  , "vs"                          = "vs" #TODO: need a definition for this variable
  , "automatic_transmission"      = "am"
  , "forward_gear_count"          = "gear"
  , "carburetor_count"            = "carb"
)

# Add a unique identifier
ds$car_id <- seq_len(nrow(ds))

# Clear up confusion about units and remove old variable
ds$weight_in_pounds <- ds$weight_in_pounds_per_1000 * 1000
ds$weight_in_pounds_per_1000 <- NULL

# Convert some to boolean variables
ds$VS <- as.logical(ds$vs)
ds$automatic_transmission <- as.logical(ds$automatic_transmission)

# Create duplicates of variables as factors (not numbers), which can help with later graphs or analyses.
#   Admittedly, the labels are a contrived example of a factor, but helps the example later.
ds$forward_gear_count_f <- factor(ds$forward_gear_count, levels=3:5, labels=c("Three", "Four", "Five"))
ds$carburetor_count_f <- factor(ds$carburetor_count)

### Create transformations and interactions to help later graphs and models.
ds$displacement_inches_cubed_log_10 <- log10(ds$displacement_inches_cubed)
ds$gross_horsepower_by_gear_count_3 <- ds$gross_horsepower * (ds$forward_gear_count=="three")
ds$gross_horsepower_by_gear_count_4 <- ds$gross_horsepower * (ds$forward_gear_count=="four")
```

```r
# I'm pretending the dataset had unreasonably low values that were artifacts of the measurement equipment.
ds$miles_per_gallon_artifact <- (ds$miles_per_gallon < 2.2)
ds$miles_per_gallon <- ifelse(ds$miles_per_gallon_artifact, NA_real_, ds$miles_per_gallon)
```

```r
# This creates z-scores WITHIN forward_gear_count levels
ds <- ds %>%
  dplyr::group_by(forward_gear_count) %>%
  dplyr::mutate(
    displacement_gear_z = as.numeric(base::scale(displacement_inches_cubed)),
    weight_gear_z       = as.numeric(base::scale(weight_in_pounds))
  ) %>%
  dplyr::ungroup()  #Always leave the dataset ungrouped, so later operations act as expected.
```

```r
# Quick inspection of the distribution of z scores within levels
ggplot2::qplot(ds$weight_gear_z, color=ds$forward_gear_count_f, geom="density")  # mean(ds$weight_gear_z, na.rm=T)
```

<img src="stitched-output/manipulation/car/graph-1.png" title="plot of chunk graph" alt="plot of chunk graph" style="display: block; margin: auto;" />

```r
# Create a boolean variable, indicating if the z scores is above a certain threshold.
ds$weight_gear_z_above_1 <- (ds$weight_gear_z > 1.00)
```

```r
testit::assert("`model_name` should be a unique value", sum(duplicated(ds$model_name))==0L)
testit::assert("`miles_per_gallon` should be a positive value.", all(ds$miles_per_gallon>0))
testit::assert("`weight_gear_z` should be a positive or missing value.", all(is.na(ds$miles_per_gallon) | (ds$miles_per_gallon>0)))
```

```r
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
readr::write_rds(ds, path_output, compress="xz")
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.3.1 (2016-06-21)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 16.04.1 LTS
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
## [1] ggplot2_2.2.1 magrittr_1.5 
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.9      knitr_1.15.1     munsell_0.4.3    testit_0.6      
##  [5] colorspace_1.3-2 lattice_0.20-34  R6_2.2.0         stringr_1.1.0   
##  [9] highr_0.6        plyr_1.8.4       dplyr_0.5.0.9000 tools_3.3.1     
## [13] grid_3.3.1       gtable_0.2.0     DBI_0.5-1        lazyeval_0.2.0  
## [17] assertthat_0.1   digest_0.6.12    tibble_1.2       readr_1.0.0     
## [21] tidyr_0.6.1      evaluate_0.10    labeling_0.3     stringi_1.1.2   
## [25] scales_0.4.1     markdown_0.7.7   zoo_1.7-14
```

```r
Sys.time()
```

```
## [1] "2017-02-11 09:59:33 CST"
```

