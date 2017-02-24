# knitr::stitch_rmd(script="./manipulation/car-ellis.R", output="./stitched-output/manipulation/car-ellis.md")
# These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr             , quietly=TRUE) #Pipes

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2"                 )
requireNamespace("readr"                   )
requireNamespace("tidyr"                   )
requireNamespace("dplyr"                   ) #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"                  ) #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
path_input  <- "./data-public/raw/mtcar.csv"
path_output <- "./data-public/derived/motor-trend-car-test.rds"
figure_path <- 'stitched-output/manipulation/car/'

premature_threshold_in_weeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeks_per_year <- 365.25/7
days_per_week <- 7

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_csv(path_input)

# ---- tweak-data --------------------------------------------------------------
colnames(ds)

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

# ---- erase-artifacts ---------------------------------------------------------
# I'm pretending the dataset had unreasonably low values that were artifacts of the measurement equipment.
ds$miles_per_gallon_artifact <- (ds$miles_per_gallon < 2.2)
ds$miles_per_gallon <- ifelse(ds$miles_per_gallon_artifact, NA_real_, ds$miles_per_gallon)

# ---- create-z-scores ---------------------------------------------------------
# This creates z-scores WITHIN forward_gear_count levels
ds <- ds %>%
  dplyr::group_by(forward_gear_count) %>%
  dplyr::mutate(
    displacement_gear_z = as.numeric(base::scale(displacement_inches_cubed)),
    weight_gear_z       = as.numeric(base::scale(weight_in_pounds))
  ) %>%
  dplyr::ungroup()  #Always leave the dataset ungrouped, so later operations act as expected.

# ---- graph, fig.width=10, fig.height=6, fig.path=figure_path ---------------------------------------------------------
# Quick inspection of the distribution of z scores within levels
ggplot2::qplot(ds$weight_gear_z, color=ds$forward_gear_count_f, geom="density")  # mean(ds$weight_gear_z, na.rm=T)

# Create a boolean variable, indicating if the z scores is above a certain threshold.
ds$weight_gear_z_above_1 <- (ds$weight_gear_z > 1.00)

# ---- verify-values -----------------------------------------------------------
testit::assert("`model_name` should be a unique value", sum(duplicated(ds$model_name))==0L)
testit::assert("`miles_per_gallon` should be a positive value.", all(ds$miles_per_gallon>0))
testit::assert("`weight_gear_z` should be a positive or missing value.", all(is.na(ds$miles_per_gallon) | (ds$miles_per_gallon>0)))

# ---- save-to-disk ------------------------------------------------------------
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
readr::write_rds(ds, path_output, compress="xz")
