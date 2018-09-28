



This report was automatically generated with the R package **knitr**
(version 1.20).


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
##   cyl = col_double(),
##   disp = col_double(),
##   hp = col_double(),
##   drat = col_double(),
##   wt = col_double(),
##   qsec = col_double(),
##   vs = col_double(),
##   am = col_double(),
##   gear = col_double(),
##   carb = col_double()
## )
```

```r
# OuhscMunge::column_rename_headstart(ds) #Spit out columns to help write call ato `dplyr::rename()`.

# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
# Populate the rename entries with OuhscMunge::column_rename_headstart(ds_county) # devtools::install_github("OuhscBbmc/OuhscMunge")
ds <-
  ds %>%
  dplyr::rename_(
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
ds <-
  ds %>%
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
## R version 3.5.1 Patched (2018-09-10 r75281)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows >= 8 x64 (build 9200)
## 
## Matrix products: default
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
## [1] DBI_1.0.0      bindrcpp_0.2.2 ggplot2_3.0.0  magrittr_1.5  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.18          pillar_1.3.0          compiler_3.5.1       
##  [4] plyr_1.8.4            highr_0.7             bindr_0.1.1          
##  [7] tools_3.5.1           bit_1.1-14            digest_0.6.17        
## [10] packrat_0.4.9-3       memoise_1.1.0         RSQLite_2.1.1        
## [13] checkmate_1.8.9-9000  lattice_0.20-35       evaluate_0.11        
## [16] tibble_1.4.2          gtable_0.2.0          viridisLite_0.3.0    
## [19] pkgconfig_2.0.2       rlang_0.2.2           cli_1.0.1            
## [22] rstudioapi_0.7        yaml_2.2.0            withr_2.1.2          
## [25] dplyr_0.7.6           stringr_1.3.1         knitr_1.20           
## [28] hms_0.4.2.9001        bit64_0.9-7           rprojroot_1.3-2      
## [31] grid_3.5.1            tidyselect_0.2.4      OuhscMunge_0.1.9.9009
## [34] glue_1.3.0            R6_2.2.2              fansi_0.3.0          
## [37] rmarkdown_1.10        blob_1.1.1            tidyr_0.8.1          
## [40] readr_1.2.0           purrr_0.2.5           scales_1.0.0         
## [43] backports_1.1.2       htmltools_0.3.6       testit_0.8.1         
## [46] rsconnect_0.8.8       assertthat_0.2.0      colorspace_1.3-2     
## [49] labeling_0.3          utf8_1.1.4            stringi_1.2.4        
## [52] lazyeval_0.2.1        munsell_0.5.0         crayon_1.3.4         
## [55] zoo_1.8-4
```

```r
Sys.time()
```

```
## [1] "2018-09-28 16:09:19 CDT"
```

