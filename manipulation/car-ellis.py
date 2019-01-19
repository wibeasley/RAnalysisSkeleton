
# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
import pandas as pd
from dfply import *

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.

path_input = "./data-public/raw/mtcar.csv"
path_output = "./data-public/derived/motor-trend-car-test.rds"
figure_path = 'stitched-output/manipulation/car/'

# Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
premature_threshold_in_weeks = 37
weeks_per_year = 365.25/7
days_per_week = 7


# ---- load-data ---------------------------------------------------------------
ds = pd.read_csv(path_input)

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds) #Spit out columns to help write call ato `dplyr::rename()`.

# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
# Populate the rename entries with OuhscMunge::column_rename_headstart(ds_county) # devtools::install_github("OuhscBbmc/OuhscMunge")
(ds2 = ds.rename(columns={
    "model"     : "model_name"
  })
)

(ds >>
 select(carb)
)


print(ds2)
# %>%
#   dplyr::mutate(
#     weight_pounds           = weight_pounds_per_1000 * 1000,     # Clear up confusion about units
#
#     engine_v_shape          = as.logical(engine_v_shape),           # Convert to boolean
#     transmission_automatic  = as.logical(transmission_automatic),   # Convert to boolean
#     horsepower_log_10       = log10(horsepower)
#   ) %>%
#   dplyr::select(
#     -weight_pounds_per_1000 # Remove old variable
#   ) %>%
#   tibble::rowid_to_column("car_id") # Add a unique identifier
#
# # ---- erase-artifacts ---------------------------------------------------------
# # I'm pretending there are low values that were artifacts of the measurement equipment.
# ds <-
#   ds %>%
#   dplyr::mutate(
#     miles_per_gallon_artifact = (miles_per_gallon < 2.2),
#     miles_per_gallon          = dplyr::if_else(miles_per_gallon_artifact, NA_real_, miles_per_gallon)
#   )
#
# # ---- create-z-scores ---------------------------------------------------------
# # This creates z-scores WITHIN forward_gear_count levels
# ds <-
#   ds %>%
#   dplyr::group_by(forward_gear_count) %>%
#   dplyr::mutate(
#     displacement_gear_z = as.numeric(base::scale(displacement_inches_cubed)),
#     weight_gear_z       = as.numeric(base::scale(weight_pounds))
#   ) %>%
#   dplyr::ungroup() %>%   #Always leave the dataset ungrouped, so later operations act as expected.
#   dplyr::mutate(
#     # Create a boolean variable, indicating if the z scores is above a certain threshold.
#     weight_gear_z_above_1 = (1 < weight_gear_z)
#   )
#
# # ---- verify-values -----------------------------------------------------------
# # OuhscMunge::verify_value_headstart(ds) # Run this to line to start the checkmate asserts.
#
# checkmate::assert_integer(  ds$car_id                       , any.missing=F , lower=   1, upper=  32  , unique=T)
# checkmate::assert_character(ds$model_name                   , any.missing=F , pattern="^.{7,19}$"     , unique=T)
# checkmate::assert_numeric(  ds$miles_per_gallon             , any.missing=F , lower=  10, upper=  34  )
# checkmate::assert_numeric(  ds$cylinder_count               , any.missing=F , lower=   4, upper=   8  )
# checkmate::assert_numeric(  ds$displacement_inches_cubed    , any.missing=F , lower=  71, upper= 472  )
# checkmate::assert_numeric(  ds$horsepower                   , any.missing=F , lower=  52, upper= 335  )
# checkmate::assert_numeric(  ds$rear_axle_ratio              , any.missing=F , lower=   2, upper=   5  )
# checkmate::assert_numeric(  ds$quarter_mile_sec             , any.missing=F , lower=  14, upper=  23  )
# checkmate::assert_logical(  ds$engine_v_shape               , any.missing=F                           )
# checkmate::assert_logical(  ds$transmission_automatic       , any.missing=F                           )
# checkmate::assert_numeric(  ds$forward_gear_count           , any.missing=F , lower=   3, upper=   5  )
# checkmate::assert_numeric(  ds$carburetor_count             , any.missing=F , lower=   1, upper=   8  )
# checkmate::assert_numeric(  ds$weight_pounds                , any.missing=F , lower=1513, upper=5424  )
# checkmate::assert_numeric(  ds$horsepower_log_10            , any.missing=F , lower=   1, upper=   3  )
# checkmate::assert_logical(  ds$miles_per_gallon_artifact    , any.missing=F                           )
# checkmate::assert_numeric(  ds$displacement_gear_z          , any.missing=F , lower=  -3, upper=   3  )
# checkmate::assert_numeric(  ds$weight_gear_z                , any.missing=F , lower=  -3, upper=   3  )
# checkmate::assert_logical(  ds$weight_gear_z_above_1        , any.missing=F                           )
#
# # ---- save-to-disk ------------------------------------------------------------
# # Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
# readr::write_rds(ds, path_output, compress="xz")
