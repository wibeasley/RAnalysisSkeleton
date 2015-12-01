# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./manipulation/stitched-output/te-ellis.md")

rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# load_sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# load_packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("car", quietly=TRUE) #For it's `recode()` function.

# declare_globals ---------------------------------------------------------
# Constant values that won't change.
path_out_unified               <- "data-phi-free/derived/county-month-te.csv"
counties_to_drop_from_rural    <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
default_day_of_month           <- 15L      # Summarize each month at its (rough) midpoint.
possible_county_ids            <- 1L:77L   #There are 77 counties.
threshold_mean_fte_t_fill_in   <- 10L      #Any county averaging over 10 hours can be filled in with its mean.

# URIs of CSV and County lookup table
path_in_oklahoma  <- "./data-phi-free/raw/te/nurse-month-oklahoma.csv"
path_in_tulsa     <- "./data-phi-free/raw/te/month-tulsa.csv"
path_in_rural     <- "./data-phi-free/raw/te/nurse-month-rural.csv"
path_county      <- "./data-phi-free/raw/te/county.csv"

# load_data ---------------------------------------------------------------
# Read the CSVs
ds_nurse_month_oklahoma <- readr::read_csv(path_in_oklahoma)
ds_month_tulsa          <- readr::read_csv(path_in_tulsa)
ds_nurse_month_rural    <- readr::read_csv(path_in_rural)
ds_county               <- readr::read_csv(path_county)

rm(path_in_oklahoma, path_in_tulsa, path_in_rural, path_county)
ds_nurse_month_oklahoma
ds_month_tulsa
ds_nurse_month_rural
ds_county

# tweak_data --------------------------------------------------------------
# ds_nurse_month_ruralOklahoma <- ds_nurse_month_rural[ds_nurse_month_rural$HOME_COUNTY=="Oklahoma", ]

# groom_oklahoma ----------------------------------------------------------

# Sanitize illegal variable names.
colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma))

# Groom the nurse-month dataset for Oklahoma County.
ds_nurse_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::rename_(
    "EmployeeNumber"    = "Employee.."         # Used to be "Employee #" before sanitizing.
    , "EmployeeName"    = "Name"
    , "Year"            = "Year"
    , "Month"           = "Month"
    , "Fte"             = "FTE"
    , "FmlaHours"       = "FMLA.Hours"         # Used to be "FMLA Hours" before sanitizing.
    , "TrainingHours"   = "Training.Hours"     # Used to be "Training Hours" before sanitizing.
  ) %>%
  dplyr::mutate(
    CountyID        = ds_county[ds_county$CountyName=="Oklahoma", ]$CountyID,  # Dynamically determine county ID.
    Month           = as.Date(ISOdate(Year, Month, default_day_of_month)),      # Combine fields for one date.
    # FmlaHours     = ifelse(!is.na(FmlaHours), FmlaHours, 0.0),             # Set missing values to zero.
    TrainingHours   = ifelse(!is.na(TrainingHours), TrainingHours, 0.0)      # Set missing values to zero.
  ) %>%
  dplyr::select(      # Drop unecessary variables (ie, defensive programming)
    -EmployeeNumber,
    -EmployeeName,
    -Year
  )
ds_nurse_month_oklahoma

# Collapse across nurses to create one record per month for Oklahoma County.
ds_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::group_by(CountyID, Month) %>%                   # Split by County & Month into sub-datasets
  dplyr::summarize(                                      # Aggregate/summarize within sub-datasets
    Fte               = sum(Fte, na.rm=T),
    # FmlaHours       = sum(FmlaHours, na.rm=T)
    FteApproximated   = FALSE                            # This variable helps the later union query.
  ) %>%
  dplyr::ungroup()                                       # Unecessary b/c of `summarize()`, but I like the habit.
ds_month_oklahoma

# The SQL equivalent to the previous dplyr code.
#   SELECT Month, CountyID, SUM(Fte) as Fte, 'FALSE' AS FteApproximated
#   FROM ds_nurse_month_oklahoma
#   GROUP BY Month, CountyID

# The un-piped equivalent to the previous dplyr code.  Notice 3 layers of nesting instead of 3 pipes.
#   ds_month_oklahoma <- dplyr::ungroup(
#     dplyr::summarize(
#       dplyr::group_by(
#         ds_nurse_month_oklahoma,
#         CountyID,
#         Month
#       ),
#       # Aggregate/summarize within sub-datasets
#       Fte               = sum(Fte, na.rm=T),
#       # FmlaHours       = sum(FmlaHours, na.rm=T)
#       FteApproximated   = FALSE                            # This variable helps the later union query.
#     )
#   )

rm(ds_nurse_month_oklahoma) #Remove this dataset so it's not accidentally used below.

# groom_tulsa -------------------------------------------------------------

# Groom the nurse-month dataset for Tulsa County.
ds_month_tulsa <- ds_month_tulsa %>%
  dplyr::rename_(
    "Month"       = "Month"
    , "Fte"       = "FteSum"
    #, "FmlaHours" = "FmlaSum"
  ) %>%
  dplyr::mutate(
    CountyID            = ds_county[ds_county$CountyName=="Tulsa", ]$CountyID,  #Dynamically determine county ID
    Month               = as.Date(Month, "%m/%d/%Y"),
    #FmlaHours          = ifelse(!is.na(FmlaHours), FmlaHours, 0.0)
    FteApproximated    = FALSE
  )  %>%
  dplyr::select(CountyID, Month, Fte, FteApproximated)
ds_month_tulsa

# groom_rural -------------------------------------------------------------

# Groom the nurse-month dataset for the 75 rurals counties.
ds_nurse_month_rural <- ds_nurse_month_rural %>%
  dplyr::rename_(
    "NameFull"            = "Name"
    , "CountyName"        = "HOME_COUNTY"
    , "RegionID"          = "REGIONID"
    , "FtePercent"        = "FTE"
    , "Month"             = "PERIOD"
  ) %>%
  dplyr::select(
    CountyName,
    Month,
    NameFull,
    FtePercent
  ) %>% # dplyr::select(NameFull, Month, CountyName, FtePercent) %>%
  dplyr::filter(!(CountyName %in% counties_to_drop_from_rural)) %>%
  dplyr::mutate(
    Month      = as.Date(paste0(Month, "-", default_day_of_month), format="%m/%Y-%d"),
    FteString  = gsub("^(\\d{1,3})%\\s+$", "\\1", FtePercent),
    Fte        = .01 * as.numeric(ifelse(nchar(FteString)==0L, 0, FteString)),
    CountyName = car::recode(CountyName, "'Cimmarron'='Cimarron';'Leflore'='Le Flore'")
  ) %>%
  dplyr::arrange(CountyName, Month, NameFull) %>%
  dplyr::select(
    -FtePercent,
    -FteString
  ) %>%
  dplyr::left_join(
    ds_county[, c("CountyID", "CountyName")], by="CountyName"
  )
ds_nurse_month_rural

# table(ds_nurse_month_rural$CountyID, useNA="always")
# table(ds_nurse_month_rural$CountyName, useNA="always")

# Collapse across nurses to create one record per month per county.
ds_month_rural <- ds_nurse_month_rural %>%
  dplyr::group_by(CountyID, Month) %>%
  dplyr::summarize(
    Fte                = sum(Fte, na.rm=TRUE),
    # FmlaHours        = sum(FmlaHours, na.rm=TRUE)
    FteApproximated    = FALSE
  ) %>%
  dplyr::ungroup()
ds_month_rural

possible_months <- seq.Date(range(ds_month_rural$Month)[1], range(ds_month_rural$Month)[2], by="month")
ds_possible <- expand.grid(Month=possible_months, CountyID=possible_county_ids, stringsAsFactors=F)

#Determine the months were we don't have any rural T&E data.
months_rural_not_collected <- (ds_month_rural %>%
  dplyr::right_join(
    ds_possible, by=c("CountyID", "Month")
  ) %>%
  dplyr::group_by(Month) %>%
  dplyr::summarize(
    MeanNA = mean(is.na(Fte))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(MeanNA >= .9999))$Month
months_rural_not_collected

rm(ds_nurse_month_rural) #Remove this dataset so it's not accidentally used below.
rm(counties_to_drop_from_rural, default_day_of_month)

# union_all_counties -----------------------------------------------------

# Stack the three datasets on top of each other.
ds <- ds_month_oklahoma %>%
  dplyr::union(
    ds_month_tulsa
  ) %>%
  dplyr::union(
    ds_month_rural
  ) %>%
  dplyr::right_join(
    ds_possible, by=c("CountyID", "Month")
  ) %>%
  dplyr::left_join(
    ds_county[, c("CountyID", "CountyName", "C1LeadNurseRegion")], by="CountyID"
  ) %>%
  dplyr::rename_("RegionID" = "C1LeadNurseRegion") %>%
  dplyr::arrange(CountyID, Month) %>%
  dplyr::mutate(
    CountyMonthID     = seq_len(n()), # Add the primary key
    Fte               = ifelse(is.na(Fte), 0, Fte),
    MonthMissing      = is.na(FteApproximated),
    FteApproximated   = MonthMissing & (Month %in% months_rural_not_collected),
    FteRollingMedian12Month = zoo::rollmedian(x=Fte, 11, na.pad=T, align="right")
  ) %>%
  dplyr::group_by(CountyID) %>%               # Group by county.
  dplyr::mutate(
    CountyAnyMissing  = any(MonthMissing)     # Determine if a county is missing any month
  ) %>%
  dplyr::ungroup()
ds

#Loop through each county to determine which (if any) months need to be approximated.
#   The dataset is small enough that it's not worth vectorizing.
for( id in sort(unique(ds$CountyID)) ) {# for( id in 13 ) {}
  ds_county <- dplyr::filter(ds, CountyID==id)
  missing <- ds_county$FteApproximated #is.na(ds_county$FteApproximated)

  # Attempt to fill in values only for counties missing something.
  if( any(ds_county$CountyAnyMissing) ) {

    #This statement interpolates missing FTE values
    ds_county$Fte[missing] <- as.numeric(approx(
      x    = ds_county$Month[!missing],
      y    = ds_county$Fte[  !missing],
      xout = ds_county$Month[ missing]
    )$y)

    #This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if( mean(ds_county$Fte, na.rm=T) >= threshold_mean_fte_t_fill_in ) {
      ds_county$FteApproximated <- (ds_county$Fte==0)
      ds_county$Fte <- ifelse(ds_county$Fte==0, ds_county$FteRollingMedian12Month, ds_county$Fte)
    }

    #Overwrite selected values in the real dataset
    ds[ds$CountyID==id, ]$Fte             <- ds_county$Fte
    ds[ds$CountyID==id, ]$FteApproximated <- ds_county$FteApproximated
  }
}
ds

rm(ds_month_oklahoma, ds_month_tulsa, ds_month_rural, ds_possible)  #Remove these datasets so it's not accidentally used below.
rm(possible_months, possible_county_ids)

# verify_values -----------------------------------------------------------
# Sniff out problems
testit::assert("The Month value must be nonmissing & since 2000", all(!is.na(ds$Month) & (ds$Month>="2012-01-01")))
testit::assert("The CountyID value must be nonmissing & positive.", all(!is.na(ds$CountyID) & (ds$CountyID>0)))
testit::assert("The CountyID value must be in [1, 77].", all(ds$CountyID %in% seq_len(77L)))
testit::assert("The RegionID value must be nonmissing & positive.", all(!is.na(ds$RegionID) & (ds$RegionID>0)))
testit::assert("The RegionID value must be in [1, 20].", all(ds$RegionID %in% seq_len(20L)))
testit::assert("The `Fte` value must be nonmissing & positive.", all(!is.na(ds$Fte) & (ds$Fte>=0)))
# testit::assert("The `FmlaHours` value must be nonmissing & nonnegative", all(is.na(ds$FmlaHours) | (ds$FmlaHours>=0)))

testit::assert("The County-Month combination should be unique.", all(!duplicated(paste(ds$CountyID, ds$Month))))
testit::assert("The Region-County-Month combination should be unique.", all(!duplicated(paste(ds$RegionID, ds$CountyID, ds$Month))))
table(paste(ds$CountyID, ds$Month))[table(paste(ds$CountyID, ds$Month))>1]

# specify_columns_to_upload -----------------------------------------------
columns_to_write <- c( "CountyMonthID", "CountyID", "Month", "Fte", "FteApproximated", "RegionID")
ds_slim <- ds[, columns_to_write]
ds_slim$FteApproximated <- as.integer(ds_slim$FteApproximated)
ds_slim

# # upload_to_db ------------------------------------------------------------
# (startTime <- Sys.time())
# dbTable <- "Osdh.tblC1TEMonth"
# channel <- RODBC::odbcConnect("te-example") #getSqlTypeInfo("Microsoft SQL Server") #;odbcGetInfo(channel)
#
# columnInfo <- RODBC::sqlColumns(channel, dbTable)
# varTypes <- as.character(columnInfo$TYPE_NAME)
# names(varTypes) <- as.character(columnInfo$COLUMN_NAME)  #varTypes
#
# RODBC::sqlClear(channel, dbTable)
# RODBC::sqlSave(channel, ds_slim, dbTable, append=TRUE, rownames=FALSE, fast=TRUE, varTypes=varTypes)
# RODBC::odbcClose(channel)
# rm(columnInfo, channel, columns_to_write, dbTable, varTypes)
# (elapsedDuration <-  Sys.time() - startTime) #21.4032 secs 2015-10-31

# save_to_disk ------------------------------------------------------------
readr::write_csv(ds, path_out_unified)

# inspect -----------------------------------------------------------------
library(ggplot2)

# Graph each county-month
ggplot(ds, aes(x=Month, y=Fte, group=factor(CountyID), color=factor(CountyID), shape=FteApproximated, ymin=0)) +
  geom_point(position=position_jitter(height=.05, width=5), size=4, na.rm=T) +
  # geom_text(aes(label=CountyMonthID)) +
  geom_line(position=position_jitter(height=.1, width=5)) +
  scale_shape_manual(values=c("TRUE"=21, "FALSE"=NA)) +
  theme_light() +
  guides(color = guide_legend(ncol=4, override.aes = list(size=3, alpha = 1))) +
  guides(shape = guide_legend(ncol=2, override.aes = list(size=3, alpha = 1))) +
  labs(title="FTE sum each month (by county)", y="Sum of FTE for County")

# Graph each region-month
ds_region <- ds %>%
  dplyr::group_by(RegionID, Month) %>%
  dplyr::summarize(
    Fte             = sum(Fte, na.rm=T),
    FteApproximated = any(FteApproximated)
  ) %>%
  dplyr::ungroup()

last_plot() %+%
  ds_region +
  aes(group=factor(RegionID), color=factor(RegionID))

# last_plot() +
#   aes(y=FmlaHours) +
#   labs(title="FmlaHours sum each month (by county)")
