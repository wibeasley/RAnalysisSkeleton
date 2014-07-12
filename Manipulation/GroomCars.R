#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
## @knitr LoadSources

############################
## @knitr LoadPackages
require(plyr)
require(ggplot2)

############################
## @knitr DeclareGlobals
options(stringsAsFactors=FALSE) #By default, character/string variables will NOT be automatically converted to factors.

pathInput <- "./DataPhiFree/Raw/mtcars_dataset.csv"
pathOutput <- "./DataPhiFree/Derived/MotorTrendCarTest.rds"

prematureThresholdInWeeks <- 37 #Any infant under 37 weeks is considered premature for the current project.  Exactly 37.0 weeks are retained.
weeksPerYear <- 365.25/7
daysPerWeek <- 7

############################
## @knitr LoadData
ds <- read.csv(pathInput)
colnames(ds)

# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
ds <- plyr::rename(ds, replace=c(
  "model" = "ModelName"
  , "mpg" = "MilesPerGallon"
  , "cyl" = "CylinderCount"
  , "disp" = "DisplacementInchesCubed"
  , "hp" = "GrossHorsepower"
  , "drat" = "RearAxleRatio"
  , "wt" = "WeightInPoundsPer1000"
  , "qsec" = "QuarterMileInSeconds"
  , "vs" = "VS" #TODO: need a definition for this variable
  , "am" = "AutomaticTransmission"
  , "gear" = "ForwardGearCount"
  , "carb" = "CarburetorCount"
))
############################
## @knitr TweakData
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

############################
## @knitr EraseArtifacts
# I'm pretending the dataset had unreasonably low values that were artifacts of the measurement equipment.
ds$MilesPerGallonArtifact <- (ds$MilesPerGallon < 2.2)
ds$MilesPerGallon <- ifelse(ds$MilesPerGallonArtifact, NA_real_, ds$MilesPerGallon)

############################
## @knitr CreateZScores
# This creates z-scores WITHIN ForwardGearCount levels
ds <- plyr::ddply(ds, .variables="ForwardGearCountF", .fun=transform, 
                  DisplacementInchesCubedZ=scale(DisplacementInchesCubed), 
                  WeightInPoundsZ=scale(WeightInPounds)
                  )
# Quick inspection of the distribution of z scores within levels
ggplot2::qplot(ds$WeightInPoundsZ, color=ds$ForwardGearCountF, geom="density")  # mean(ds$WeightInPoundsZ, na.rm=T)

# Create a boolean variable, indicating if the z scores is above a certain threshold.
ds$WeightInPoundsZAbove1 <- (ds$WeightInPoundsZ > 1.00)
############################
## @knitr SaveToDisk
# Save as a compress, binary R dataset.  It's no longer readable with a text editor, but it saves metadata (eg, factor information).
saveRDS(ds, file=pathOutput, compress="xz")
