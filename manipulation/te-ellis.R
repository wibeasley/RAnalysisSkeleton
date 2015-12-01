rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# load_sources ------------------------------------------------------------

# load_packages -----------------------------------------------------------
# For the packages that must be attached
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)
requireNamespace("readr", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("car", quietly=TRUE) #For it's `recode()` function.

# declare_globals ---------------------------------------------------------
pathOutUnified <- "data-phi-free/derived/county-month-te.csv"
defaultDayOfMonth <- 15L
countiesToDropFromRural <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
possibleCountyIDs <- 1L:77L
thresholdMeanFteToFillIn <- 10L #Any county averaging over 10 hours can be filled in with its mean.

# load_data ---------------------------------------------------------------

# URIs of CSV and County lookup table
pathInOklahoma  <- "./data-phi-free/raw/te/nurse-month-oklahoma.csv"
pathInTulsa     <- "./data-phi-free/raw/te/month-tulsa.csv"
pathInRural     <- "./data-phi-free/raw/te/nurse-month-rural.csv"
pathCounty      <- "./data-phi-free/raw/te/county.csv"

# Read the CSVs
dsNurseMonthOklahoma <- readr::read_csv(pathInOklahoma)
dsMonthTulsa         <- readr::read_csv(pathInTulsa)
dsNurseMonthRural    <- readr::read_csv(pathInRural)
dsCounty             <- readr::read_csv(pathCounty)
rm(pathInOklahoma, pathInTulsa, pathInRural, pathCounty)

# tweak_data --------------------------------------------------------------
# dsNurseMonthRuralOklahoma <- dsNurseMonthRural[dsNurseMonthRural$HOME_COUNTY=="Oklahoma", ]

# groom_oklahoma ----------------------------------------------------------
colnames(dsNurseMonthOklahoma) <- make.names(colnames(dsNurseMonthOklahoma)) #Sanitize illegal variable names.
dsNurseMonthOklahoma <- dsNurseMonthOklahoma %>%
  dplyr::rename_(
    "EmployeeNumber"    = "Employee.."
    , "EmployeeName"    = "Name"
    , "Year"            = "Year"
    , "Month"           = "Month"
    , "Fte"             = "FTE"
    , "FmlaHours"       = "FMLA.Hours"
    , "TrainingHours"   = "Training.Hours"
  ) %>%
  dplyr::mutate(
    CountyID        = dsCounty[dsCounty$CountyName=="Oklahoma", ]$CountyID,
    Month           = as.Date(ISOdate(Year, Month, defaultDayOfMonth)),
    #FmlaHours       = ifelse(!is.na(FmlaHours), FmlaHours, 0.0),
    TrainingHours   = ifelse(!is.na(TrainingHours), TrainingHours, 0.0)
  ) %>%
  dplyr::select(
    -EmployeeNumber,
    -EmployeeName,
    -Year
  )

# The SQL equivalent to the following dplyr code it:
#     SELECT Month, CountyID, SUM(Fte) as Fte, 'FALSE' AS FteApproximated
#     FROM dsNurseMonthOklahoma
#     GROUP BY Month, CountyID
dsMonthOklahoma <- dsNurseMonthOklahoma %>%
  dplyr::group_by(CountyID, Month) %>%
  dplyr::summarise(
    Fte               = sum(Fte, na.rm=T),
    #FmlaHours         = sum(FmlaHours, na.rm=T)
    FteApproximated   = FALSE
  ) %>%
  dplyr::ungroup()

rm(dsNurseMonthOklahoma) #Remove this dataset so it's not accidentally used below.

# groom_tulsa -------------------------------------------------------------
dsMonthTulsa <- dsMonthTulsa %>%
  dplyr::rename_(
    "Month"       = "Month"
    , "Fte"       = "FteSum"
    #, "FmlaHours" = "FmlaSum"
  ) %>%
  dplyr::mutate(
    CountyID            = dsCounty[dsCounty$CountyName=="Tulsa", ]$CountyID,
    Month               = as.Date(Month, "%m/%d/%Y"),
    #FmlaHours          = ifelse(!is.na(FmlaHours), FmlaHours, 0.0)
    FteApproximated    = FALSE
  )  %>%
  dplyr::select(CountyID, Month, Fte, FteApproximated)

# groom_rural -------------------------------------------------------------
dsNurseMonthRural <- dsNurseMonthRural %>%
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
  dplyr::filter(!(CountyName %in% countiesToDropFromRural)) %>%
  dplyr::mutate(
    Month      = as.Date(paste0(Month, "-", defaultDayOfMonth), format="%m/%Y-%d"),
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
    dsCounty[, c("CountyID", "CountyName")], by="CountyName"
  )

# table(dsNurseMonthRural$CountyID, useNA="always")
# table(dsNurseMonthRural$CountyName, useNA="always")

dsMonthRural <- dsNurseMonthRural %>%
  dplyr::group_by(CountyID, Month) %>%
  dplyr::summarize(
    Fte                = sum(Fte, na.rm=TRUE),
    #FmlaHours          = sum(FmlaHours, na.rm=TRUE)
    FteApproximated    = FALSE
  ) %>%
  dplyr::ungroup()

possibleMonths <- seq.Date(range(dsMonthRural$Month)[1], range(dsMonthRural$Month)[2], by="month")
dsPossible <- expand.grid(Month=possibleMonths, CountyID=possibleCountyIDs, stringsAsFactors=F)

#These are the months were we don't have any rural T&E data.
monthsRuralNotCollected <- (dsMonthRural %>%
  dplyr::right_join(
    dsPossible, by=c("CountyID", "Month")
  ) %>%
  dplyr::group_by(Month) %>%
  dplyr::summarize(
    MeanNA = mean(is.na(Fte))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(MeanNA >= .9999))$Month

rm(dsNurseMonthRural) #Remove this dataset so it's not accidentally used below.
rm(countiesToDropFromRural, defaultDayOfMonth)

# union_all_counties -----------------------------------------------------

ds <- dsMonthOklahoma %>%
  dplyr::union(
    dsMonthTulsa
  ) %>%
  dplyr::union(
    dsMonthRural
  ) %>%
  dplyr::right_join(
    dsPossible, by=c("CountyID", "Month")
  ) %>%
  dplyr::left_join(
    dsCounty[, c("CountyID", "CountyName", "C1LeadNurseRegion")], by="CountyID"
  ) %>%
  dplyr::rename_("RegionID" = "C1LeadNurseRegion") %>%
  dplyr::arrange(CountyID, Month) %>%
  dplyr::mutate(
    CountyMonthID     = seq_len(n()), # Add the primary key
    Fte               = ifelse(is.na(Fte), 0, Fte),
    MonthMissing      = is.na(FteApproximated),
    FteApproximated   = MonthMissing & (Month %in% monthsRuralNotCollected),
    FteRollingMedian12Month = zoo::rollmedian(x=Fte, 11, na.pad=T, align="right")
  ) %>%
  dplyr::group_by(CountyID) %>%
  dplyr::mutate(
    CountyAnyMissing  = any(MonthMissing)
  ) %>%
  dplyr::ungroup()

# for( countyID in 13 ) {}
for( countyID in sort(unique(ds$CountyID)) ) {
  dsCounty <- dplyr::filter(ds, CountyID==countyID)
  missing <- dsCounty$FteApproximated #is.na(dsCounty$FteApproximated)

  # Attempt to fill in values only for counties missing something.
  if( any(dsCounty$CountyAnyMissing)  ) {

    #This statement interpolates missing FTE values
    dsCounty$Fte[missing] <- as.numeric(approx(
      x    = dsCounty$Month[!missing],
      y    = dsCounty$Fte[  !missing],
      xout = dsCounty$Month[ missing]
    )$y)

    #This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if( mean(dsCounty$Fte, na.rm=T) >= thresholdMeanFteToFillIn ) {
      dsCounty$FteApproximated <- (dsCounty$Fte==0)
      dsCounty$Fte <- ifelse(dsCounty$Fte==0, dsCounty$FteRollingMedian12Month, dsCounty$Fte)
    }

    #Overwrite selected values in the real dataset
    ds[ds$CountyID==countyID, ]$Fte             <- dsCounty$Fte
    ds[ds$CountyID==countyID, ]$FteApproximated <- dsCounty$FteApproximated
  }
}

rm(dsMonthOklahoma, dsMonthTulsa, dsMonthRural, dsPossible)  #Remove these datasets so it's not accidentally used below.
rm(possibleMonths, possibleCountyIDs)

# verify_values -----------------------------------------------------------
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
columnsToWrite <- c( "CountyMonthID", "CountyID", "Month", "Fte", "FteApproximated", "RegionID")
dsSlim <- ds[, columnsToWrite]
dsSlim$FteApproximated <- as.integer(dsSlim$FteApproximated)

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
# RODBC::sqlSave(channel, dsSlim, dbTable, append=TRUE, rownames=FALSE, fast=TRUE, varTypes=varTypes)
# RODBC::odbcClose(channel)
# rm(columnInfo, channel, columnsToWrite, dbTable, varTypes)
# (elapsedDuration <-  Sys.time() - startTime) #21.4032 secs 2015-10-31

# save_to_disk ------------------------------------------------------------
readr::write_csv(ds, pathOutUnified)

# inspect -----------------------------------------------------------------
library(ggplot2)
ggplot(ds, aes(x=Month, y=Fte, group=factor(CountyID), color=factor(CountyID), shape=FteApproximated, ymin=0)) +
  geom_point(position=position_jitter(height=.05, width=5), size=4, na.rm=T) +
  # geom_text(aes(label=CountyMonthID)) +
  geom_line(position=position_jitter(height=.1, width=5)) +
  scale_shape_manual(values=c("TRUE"=21, "FALSE"=NA)) +
  theme_light() +
  guides(color = guide_legend(ncol=4, override.aes = list(size=3, alpha = 1))) +
  guides(shape = guide_legend(ncol=2, override.aes = list(size=3, alpha = 1))) +
  labs(title="FTE sum each month (by county)", y="Sum of FTE for County")

dsRegion <- ds %>%
  dplyr::group_by(RegionID, Month) %>%
  dplyr::summarize(
    Fte             = sum(Fte, na.rm=T),
    FteApproximated = any(FteApproximated)
  ) %>%
  dplyr::ungroup()

last_plot() %+%
  dsRegion +
  aes(group=factor(RegionID), color=factor(RegionID))

# last_plot() +
#   aes(y=FmlaHours) +
#   labs(title="FmlaHours sum each month (by county)")
