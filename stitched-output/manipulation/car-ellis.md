



This report was automatically generated with the R package **knitr**
(version 1.26).


```r
# knitr::stitch_rmd(script="manipulation/car-ellis.R", output="stitched-output/manipulation/car-ellis.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
```

```r
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
```

```r
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
# library("ggplot2")

# Import only certain functions of a package into the search path.
import::from("magrittr", "%>%")

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"                   )
```

```
## Loading required namespace: readr
```

```r
requireNamespace("tidyr"                   )
```

```
## Loading required namespace: tidyr
```

```r
requireNamespace("dplyr"                   ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"                  ) # For asserting conditions meet expected patterns.
```

```
## Loading required namespace: testit
```

```r
# Constant values that won't change.
# config                  <- config::get()
# path_input              <- config$path_car_raw
# path_output             <- config$path_car_derived
# Uncomment the lines above and delete the two below if values are stored in 'config.yml'.

path_input  <- "data-public/raw/mtcar.csv"
path_output <- "data-public/derived/car.rds"
figure_path <- 'stitched-output/manipulation/car/'

miles_per_gallon_threshold    <- 2.2 # I'm pretending that low values that are artifacts of the measurement equipment.
days_per_week                 <- 7L
weeks_per_year                <- 365.25 / days_per_week
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
rm(path_input)
```

```r
# OuhscMunge::column_rename_headstart(ds_county) # Help write `dplyr::select()` call.

# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
# Populate the rename entries with OuhscMunge::column_rename_headstart(ds_county) # remotes::install_github("OuhscBbmc/OuhscMunge")
ds <-
  ds %>%
  dplyr::select(    # `dplyr::select()` drops columns not included.
    model_name                  = model,
    miles_per_gallon            = mpg,
    cylinder_count              = cyl,
    displacement_inches_cubed   = disp,
    horsepower                  = hp,
    rear_axle_ratio             = drat,
    weight_pounds_per_1000      = wt,
    quarter_mile_sec            = qsec,
    engine_v_shape              = vs,
    transmission_automatic      = am,
    forward_gear_count          = gear,
    carburetor_count            = carb
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
ds <-
  ds %>%
  dplyr::mutate(
    miles_per_gallon_artifact = (miles_per_gallon < miles_per_gallon_threshold),
    miles_per_gallon          = dplyr::if_else(miles_per_gallon_artifact, NA_real_, miles_per_gallon)
  )
```

```r
# This creates z-scores WITHIN forward_gear_count levels
ds <-
  ds %>%
  dplyr::group_by(forward_gear_count) %>%
  dplyr::mutate(
    displacement_gear_z = base::scale(displacement_inches_cubed),
    weight_gear_z       = base::scale(weight_pounds)
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
# Print colnames that `dplyr::select()`  should contain below:
#   cat(paste0("    ", colnames(ds), collapse=",\n"))

# Define the subset of columns that will be needed in the analyses.
#   The fewer columns that are exported, the fewer things that can break downstream.
#   The variables below aren't currently included in the analyses.
#   * rear_axle_ratio,
#   * engine_v_shape,
#   * transmission_automatic,
#   * weight_pounds,
#   * horsepower_log_10,
#   * miles_per_gallon_artifact,
#   * displacement_gear_z


ds_slim <-
  ds %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(
    car_id,
    model_name,
    miles_per_gallon,
    displacement_inches_cubed,
    cylinder_count,
    horsepower,
    quarter_mile_sec,
    forward_gear_count,
    carburetor_count,
    weight_gear_z,
    weight_gear_z_above_1
  ) %>%
  dplyr::mutate_if(is.logical, as.integer)       # Some databases & drivers need 0/1 instead of FALSE/TRUE.
ds_slim
```

```
## # A tibble: 32 x 11
##    car_id model_name miles_per_gallon displacement_in… cylinder_count
##     <int> <chr>                 <dbl>            <dbl>          <dbl>
##  1      1 Mazda RX4              21               160               6
##  2      2 Mazda RX4…             21               160               6
##  3      3 Datsun 710             22.8             108               4
##  4      4 Hornet 4 …             21.4             258               6
##  5      5 Hornet Sp…             18.7             360               8
##  6      6 Valiant                18.1             225               6
##  7      7 Duster 360             14.3             360               8
##  8      8 Merc 240D              24.4             147.              4
##  9      9 Merc 230               22.8             141.              4
## 10     10 Merc 280               19.2             168.              6
## # … with 22 more rows, and 6 more variables: horsepower <dbl>,
## #   quarter_mile_sec <dbl>, forward_gear_count <dbl>,
## #   carburetor_count <dbl>, weight_gear_z <dbl>,
## #   weight_gear_z_above_1 <int>
```

```r
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
readr::write_rds(ds_slim, path_output, compress="gz")
```

```r
# This last section is kinda cheating, and should belong in an 'analysis' file, not a 'manipulation' file.
#   It's included here for the sake of demonstration.
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.6.1 (2019-07-05)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 19.10
## 
## Matrix products: default
## BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.8.0
## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.8.0
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
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.3       knitr_1.26       magrittr_1.5     hms_0.5.2       
##  [5] tidyselect_0.2.5 testit_0.11      R6_2.4.1         rlang_0.4.2     
##  [9] fansi_0.4.0      stringr_1.4.0    dplyr_0.8.3      tools_3.6.1     
## [13] import_1.1.0     packrat_0.5.0    checkmate_2.0.0  xfun_0.11       
## [17] utf8_1.1.4       cli_1.1.0        assertthat_0.2.1 tibble_2.1.3    
## [21] lifecycle_0.1.0  crayon_1.3.4     purrr_0.3.3      readr_1.3.1     
## [25] tidyr_1.0.0      vctrs_0.2.0      zeallot_0.1.0    glue_1.3.1      
## [29] evaluate_0.14    stringi_1.4.3    compiler_3.6.1   pillar_1.4.2    
## [33] backports_1.1.5  pkgconfig_2.0.3
```

```r
Sys.time()
```

```
## [1] "2019-12-08 00:17:08 CST"
```

