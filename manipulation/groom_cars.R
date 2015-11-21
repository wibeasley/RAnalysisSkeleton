# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# @knitr load_sources ------------------------------------------------------------

# @knitr load_packages -----------------------------------------------------------
library(ggplot2)
library(magrittr) #Pipes
requireNamespace("dplyr", quietly=TRUE)
# requireNamespace("plyr", quietly=TRUE)
requireNamespace("testit", quietly=TRUE)

# @knitr declare_globals ---------------------------------------------------------
pathInput <- "./data_phi_free/raw/mtcars_dataset.csv"
pathOutput <- "./data_phi_free/derived/motor_trend_car_test.rds"

prematureThresholdInWeeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeksPerYear <- 365.25/7
daysPerWeek <- 7

# @knitr load_data ---------------------------------------------------------------
ds <- read.csv(pathInput, stringsAsFactors=FALSE)
# @knitr tweak_data --------------------------------------------------------------
colnames(ds)

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

# @knitr erase_artifacts ---------------------------------------------------------
# I'm pretending the dataset had unreasonably low values that were artifacts of the measurement equipment.
ds$MilesPerGallonArtifact <- (ds$MilesPerGallon < 2.2)
ds$MilesPerGallon <- ifelse(ds$MilesPerGallonArtifact, NA_real_, ds$MilesPerGallon)

# @knitr create_z_scores ---------------------------------------------------------
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

# Create a boolean variable, indicating if the z scores is above a certain threshold.
ds$WeightGearZAbove1 <- (ds$WeightGearZ > 1.00)

# @knitr verify_values -----------------------------------------------------------
testit::assert("`ModelName` should be a unique value", sum(duplicated(ds$ModelName))==0L)
testit::assert("`MilesPerGallon` should be a positive value.", all(ds$MilesPerGallon>0))
testit::assert("`WeightGearZ` should be a positive or missing value.", all(is.na(ds$MilesPerGallon) | (ds$MilesPerGallon>0)))

# @knitr save_to_disk ------------------------------------------------------------
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
saveRDS(ds, file=pathOutput, compress="xz")
