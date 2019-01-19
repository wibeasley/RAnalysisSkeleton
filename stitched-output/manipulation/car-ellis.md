



This report was automatically generated with the R package **knitr**
(version 1.21).


```r
# knitr::stitch_rmd(script="./manipulation/car-ellis.R", output="./stitched-output/manipulation/car-ellis.md")
# These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  # Clear the variables from previous runs.
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
requireNamespace("dplyr"                   ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"                  ) # For asserting conditions meet expected patterns.
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
# OuhscMunge::column_rename_headstart(ds) # Spit out columns to help populate arguments to `dplyr::rename()` or `dplyr::select()`.

# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
# Populate the rename entries with OuhscMunge::column_rename_headstart(ds_county) # devtools::install_github("OuhscBbmc/OuhscMunge")
ds <-
  ds %>%
  dplyr::select_( # `dplyr::select()` implicitly drops the other columns not mentioned.
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
# Print colnames that `columns_to_write` should contain: dput(colnames(ds))
#   Use this array to adjust which variables are saved, and their position within the dataset.
columns_to_write <- c(
  "car_id",
  "model_name",
  "miles_per_gallon",
  "displacement_inches_cubed",
  "cylinder_count",
  "horsepower",
  "quarter_mile_sec",
  "forward_gear_count",
  "carburetor_count",
  "weight_gear_z",
  "weight_gear_z_above_1"

  # The variables below aren't currently included in the analyses.
  # "rear_axle_ratio",
  # "engine_v_shape",
  # "transmission_automatic",
  # "weight_pounds",
  # "horsepower_log_10",
  # "miles_per_gallon_artifact",
  # "displacement_gear_z"
)

# Define the subset of columns that will be needed in the analyses.
#   The fewer columns that are exported, the fewer things that can break downstream.
ds_slim <-
  ds %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(!!columns_to_write) %>%
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
rm(columns_to_write)
```

```r
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
readr::write_rds(ds_slim, path_output, compress="xz")
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.5.2 (2018-12-20)
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
## [1] ggplot2_3.1.0  bindrcpp_0.2.2 magrittr_1.5  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.0            highr_0.7             plyr_1.8.4           
##  [4] pillar_1.3.1          compiler_3.5.2        bindr_0.1.1          
##  [7] tools_3.5.2           digest_0.6.18         packrat_0.5.0        
## [10] bit_1.1-14            viridisLite_0.3.0     evaluate_0.12        
## [13] gtable_0.2.0          RSQLite_2.1.1         memoise_1.1.0        
## [16] tibble_2.0.1          checkmate_1.9.0       lattice_0.20-38      
## [19] pkgconfig_2.0.2       rlang_0.3.1           DBI_1.0.0            
## [22] cli_1.0.1             rstudioapi_0.9.0      yaml_2.2.0           
## [25] xfun_0.4              stringr_1.3.1         knitr_1.21           
## [28] withr_2.1.2           dplyr_0.7.8           hms_0.4.2.9001       
## [31] bit64_0.9-7           grid_3.5.2            tidyselect_0.2.5     
## [34] OuhscMunge_0.1.9.9009 glue_1.3.0            R6_2.3.0             
## [37] fansi_0.4.0           rmarkdown_1.11        tidyr_0.8.2          
## [40] readr_1.3.1           purrr_0.2.5           blob_1.1.1           
## [43] htmltools_0.3.6       scales_1.0.0.9000     backports_1.1.3      
## [46] rsconnect_0.8.13      assertthat_0.2.0      testit_0.9           
## [49] colorspace_1.4-0      labeling_0.3          utf8_1.1.4           
## [52] stringi_1.2.4         lazyeval_0.2.1        munsell_0.5.0        
## [55] markdown_0.9          crayon_1.3.4          zoo_1.8-4
```

```r
Sys.time()
```

```
## [1] "2019-01-19 17:43:32 CST"
```

