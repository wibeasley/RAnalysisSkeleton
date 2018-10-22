



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
# Constant values that won't change.
# config                  <- config::get()
# path_input              <- config$path_car_raw
# path_output             <- config$path_car_derived
# Uncomment the lines above and delete the two below if values are stored in 'config.yml'.

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
    , "horsepower"                  = "hp"
    , "rear_axle_ratio"             = "drat"
    , "weight_pounds_per_1000"      = "wt"
    , "quarter_mile_sec"            = "qsec"
    , "engine_v_shape"              = "vs"
    , "transmission_automatic"      = "am"
    , "forward_gear_count"          = "gear"
    , "carburetor_count"            = "carb"
  ) %>%
  dplyr::mutate(
    weight_pounds           = weight_pounds_per_1000 * 1000,     # Clear up confusion about units

    engine_v_shape          = as.logical(engine_v_shape),           # Convert to boolean
    transmission_automatic  = as.logical(transmission_automatic),   # Convert to boolean
    horsepower_log_10       = log10(horsepower)
  ) %>%
  dplyr::select(
    -weight_pounds_per_1000 # Remove old variable
  ) %>%
  tibble::rowid_to_column("car_id") # Add a unique identifier
```

```r
# I'm pretending there are low values that were artifacts of the measurement equipment.
ds <-
  ds %>%
  dplyr::mutate(
    miles_per_gallon_artifact = (miles_per_gallon < 2.2),
    miles_per_gallon          = dplyr::if_else(miles_per_gallon_artifact, NA_real_, miles_per_gallon)
  )
```

```r
# This creates z-scores WITHIN forward_gear_count levels
ds <-
  ds %>%
  dplyr::group_by(forward_gear_count) %>%
  dplyr::mutate(
    displacement_gear_z = as.numeric(base::scale(displacement_inches_cubed)),
    weight_gear_z       = as.numeric(base::scale(weight_pounds))
  ) %>%
  dplyr::ungroup() %>%   #Always leave the dataset ungrouped, so later operations act as expected.
  dplyr::mutate(
    # Create a boolean variable, indicating if the z scores is above a certain threshold.
    weight_gear_z_above_1 = (1 < weight_gear_z)
  )
```

```r
# OuhscMunge::verify_value_headstart(ds) # Run this to line to start the checkmate asserts.

checkmate::assert_integer(  ds$car_id                       , any.missing=F , lower=   1, upper=  32  , unique=T)
checkmate::assert_character(ds$model_name                   , any.missing=F , pattern="^.{7,19}$"     , unique=T)
checkmate::assert_numeric(  ds$miles_per_gallon             , any.missing=F , lower=  10, upper=  34  )
checkmate::assert_numeric(  ds$cylinder_count               , any.missing=F , lower=   4, upper=   8  )
checkmate::assert_numeric(  ds$displacement_inches_cubed    , any.missing=F , lower=  71, upper= 472  )
checkmate::assert_numeric(  ds$horsepower                   , any.missing=F , lower=  52, upper= 335  )
checkmate::assert_numeric(  ds$rear_axle_ratio              , any.missing=F , lower=   2, upper=   5  )
checkmate::assert_numeric(  ds$quarter_mile_sec             , any.missing=F , lower=  14, upper=  23  )
checkmate::assert_logical(  ds$engine_v_shape               , any.missing=F                           )
checkmate::assert_logical(  ds$transmission_automatic       , any.missing=F                           )
checkmate::assert_numeric(  ds$forward_gear_count           , any.missing=F , lower=   3, upper=   5  )
checkmate::assert_numeric(  ds$carburetor_count             , any.missing=F , lower=   1, upper=   8  )
checkmate::assert_numeric(  ds$weight_pounds                , any.missing=F , lower=1513, upper=5424  )
checkmate::assert_numeric(  ds$horsepower_log_10            , any.missing=F , lower=   1, upper=   3  )
checkmate::assert_logical(  ds$miles_per_gallon_artifact    , any.missing=F                           )
checkmate::assert_numeric(  ds$displacement_gear_z          , any.missing=F , lower=  -3, upper=   3  )
checkmate::assert_numeric(  ds$weight_gear_z                , any.missing=F , lower=  -3, upper=   3  )
checkmate::assert_logical(  ds$weight_gear_z_above_1        , any.missing=F                           )
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
## R version 3.5.1 (2018-07-02)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 18.04.1 LTS
## 
## Matrix products: default
## BLAS: /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1
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
## [1] ggplot2_3.0.0  DBI_1.0.0      bindrcpp_0.2.2 magrittr_1.5  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.19                lattice_0.20-35            
##  [3] tidyr_0.8.1                 prettyunits_1.0.2          
##  [5] ps_1.2.0                    zoo_1.8-4                  
##  [7] assertthat_0.2.0            rprojroot_1.3-2            
##  [9] digest_0.6.18               packrat_0.4.9-3            
## [11] utf8_1.1.4                  R6_2.3.0                   
## [13] plyr_1.8.4                  backports_1.1.2            
## [15] RSQLite_2.1.1               evaluate_0.12              
## [17] highr_0.7                   pillar_1.3.0               
## [19] rlang_0.2.2                 lazyeval_0.2.1             
## [21] callr_3.0.0                 blob_1.1.1                 
## [23] checkmate_1.8.9-9000        rmarkdown_1.10             
## [25] config_0.3                  desc_1.2.0                 
## [27] labeling_0.3                devtools_2.0.0             
## [29] readr_1.2.0                 stringr_1.3.1              
## [31] bit_1.1-14                  munsell_0.5.0              
## [33] compiler_3.5.1              pkgconfig_2.0.2            
## [35] base64enc_0.1-3             pkgbuild_1.0.2             
## [37] htmltools_0.3.6             tidyselect_0.2.5           
## [39] tibble_1.4.2                viridisLite_0.3.0          
## [41] fansi_0.4.0                 crayon_1.3.4               
## [43] dplyr_0.7.7                 withr_2.1.2                
## [45] grid_3.5.1                  gtable_0.2.0               
## [47] scales_1.0.0                TabularManifest_0.1-16.9003
## [49] cli_1.0.1                   stringi_1.2.4              
## [51] fs_1.2.6                    remotes_2.0.0              
## [53] testit_0.8                  testthat_2.0.1             
## [55] tools_3.5.1                 bit64_0.9-7                
## [57] OuhscMunge_0.1.9.9009       glue_1.3.0                 
## [59] markdown_0.8                purrr_0.2.5                
## [61] hms_0.4.2.9001              rsconnect_0.8.8            
## [63] processx_3.2.0              pkgload_1.0.1              
## [65] yaml_2.2.0                  colorspace_1.3-2           
## [67] sessioninfo_1.1.0           memoise_1.1.0              
## [69] knitr_1.20                  bindr_0.1.1                
## [71] usethis_1.4.0
```

```r
Sys.time()
```

```
## [1] "2018-10-22 08:46:45 CDT"
```

