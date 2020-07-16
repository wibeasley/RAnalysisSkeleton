# knitr::stitch_rmd(script="manipulation/car-ellis.R", output="stitched-output/manipulation/car-ellis.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
# library("ggplot2")

# Import only certain functions of a package into the search path.
import::from("magrittr", "%>%")

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"                   )
requireNamespace("tidyr"                   )
requireNamespace("dplyr"                   ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"                  ) # For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
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

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_csv(path_input)

rm(path_input)

# ---- tweak-data --------------------------------------------------------------
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
    carburetor_count            = carb,
  ) %>%
  dplyr::mutate(
    weight_pounds           = weight_pounds_per_1000 * 1000,     # Clear up confusion about units

    engine_v_shape          = as.logical(engine_v_shape),           # Convert to boolean
    transmission_automatic  = as.logical(transmission_automatic),   # Convert to boolean
    horsepower_log_10       = log10(horsepower),
  ) %>%
  dplyr::select(
    -weight_pounds_per_1000, # Remove old variable
  ) %>%
  tibble::rowid_to_column("car_id") # Add a unique identifier

# ---- erase-artifacts ---------------------------------------------------------
ds <-
  ds %>%
  dplyr::mutate(
    miles_per_gallon_artifact = (miles_per_gallon < miles_per_gallon_threshold),
    miles_per_gallon          = dplyr::if_else(miles_per_gallon_artifact, NA_real_, miles_per_gallon),
  )

# ---- create-z-scores ---------------------------------------------------------
# This creates z-scores WITHIN forward_gear_count levels
ds <-
  ds %>%
  dplyr::group_by(forward_gear_count) %>%
  dplyr::mutate(
    displacement_gear_z = base::scale(displacement_inches_cubed),
    weight_gear_z       = base::scale(weight_pounds),
  ) %>%
  dplyr::ungroup() %>%   # Always leave the dataset ungrouped, so later operations act as expected.
  dplyr::mutate(
    # Create a boolean variable, indicating if the z scores is above a certain threshold.
    weight_gear_z_above_1 = (1 < weight_gear_z),
  )

# ---- verify-values -----------------------------------------------------------
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

# ---- specify-columns-to-write ------------------------------------------------
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
    weight_gear_z_above_1,
  ) %>%
  dplyr::mutate_if(is.logical, as.integer)       # Some databases & drivers need 0/1 instead of FALSE/TRUE.
ds_slim


# ---- save-to-disk ------------------------------------------------------------
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
readr::write_rds(ds_slim, path_output, compress="gz")

# ---- inspect, fig.width=10, fig.height=6, fig.path=figure_path -----------------------------------------------------------------
# This last section is kinda cheating, and should belong in an 'analysis' file, not a 'manipulation' file.
#   It's included here for the sake of demonstration.
