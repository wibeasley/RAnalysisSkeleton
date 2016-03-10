# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./manipulation/stitched-output/te-ellis.md")
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr")
requireNamespace("tidyr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.
requireNamespace("car") #For it's `recode()` function.

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
path_out_unified               <- "data-phi-free/derived/county-month-te.csv"
counties_to_drop_from_rural    <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
default_day_of_month           <- 15L      # Summarize each month at its (rough) midpoint.
possible_county_ids            <- 1L:77L   #There are 77 counties.
threshold_mean_fte_t_fill_in   <- 10L      #Any county averaging over 10 hours can be filled in with its mean.
figure_path <- 'manipulation/stitched-output/te/'

# URIs of CSV and County lookup table
path_in_oklahoma  <- "./data-phi-free/raw/te/nurse-month-oklahoma.csv"
path_in_tulsa     <- "./data-phi-free/raw/te/month-tulsa.csv"
path_in_rural     <- "./data-phi-free/raw/te/nurse-month-rural.csv"
path_county       <- "./data-phi-free/raw/te/county.csv"

# ---- load-data ---------------------------------------------------------------
# Read the CSVs
ds_nurse_month_oklahoma <- readr::read_csv(path_in_oklahoma)
ds_month_tulsa          <- readr::read_csv(path_in_tulsa)
ds_nurse_month_rural    <- readr::read_csv(path_in_rural, col_types=readr::cols("FTE"=readr::col_character()))
ds_county               <- readr::read_csv(path_county)

rm(path_in_oklahoma, path_in_tulsa, path_in_rural, path_county)
ds_nurse_month_oklahoma
ds_month_tulsa
ds_nurse_month_rural
ds_county

# ---- tweak-data --------------------------------------------------------------
# ds_nurse_month_ruralOklahoma <- ds_nurse_month_rural[ds_nurse_month_rural$HOME_COUNTY=="Oklahoma", ]

# Populate the rename entries with column_rename_headstart() in https://github.com/OuhscBbmc/OuhscMunge/blob/master/R/data-frame-metadata.R.
ds_county <- ds_county %>%
  dplyr::select_( #`select()` implicitly drops the 7 other columns not mentioned.
    "county_id"     = "CountyID",
    "county_name"   = "CountyName",
    "region_id"     = "C1LeadNurseRegion"
  )
  
# ---- groom-oklahoma ----------------------------------------------------------
# Sanitize illegal variable names.
colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma))
# OuhscMunge::column_rename_headstart(ds_nurse_month_oklahoma) #Spit out columns to help write call ato `dplyr::rename()`.

# Groom the nurse-month dataset for Oklahoma County.
ds_nurse_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::rename_(
    "employee_number"   = "Employee.."         # Used to be "Employee #" before sanitizing.
    , "employee_name"   = "Name"
    , "year"            = "Year"
    , "month"           = "Month"
    , "fte"             = "FTE"
    , "fmla_hours"      = "FMLA.Hours"         # Used to be "FMLA Hours" before sanitizing.
    , "training_hours"  = "Training.Hours"     # Used to be "Training Hours" before sanitizing.
  ) %>%
  dplyr::mutate(
    county_id       = ds_county[ds_county$county_name=="Oklahoma", ]$county_id,  # Dynamically determine county ID.
    month           = as.Date(ISOdate(year, month, default_day_of_month)),     # Combine fields for one date.
    # fmla_hours    = ifelse(!is.na(fmla_hours), fmla_hours, 0.0),             # Set missing values to zero.
    training_hours  = ifelse(!is.na(training_hours), training_hours, 0.0)      # Set missing values to zero.
  ) %>%
  dplyr::select(      # Drop unecessary variables (ie, defensive programming)
    -employee_number,
    -employee_name,
    -year
  )
ds_nurse_month_oklahoma

# Collapse across nurses to create one record per month for Oklahoma County.
ds_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::group_by(county_id, month) %>%                   # Split by County & month into sub-datasets
  dplyr::summarize(                                      # Aggregate/summarize within sub-datasets
    fte                = sum(fte, na.rm=T),
    # fmla_hours       = sum(fmla_hours, na.rm=T)
    fte_approximated   = FALSE                           # This variable helps the later union query.
  ) %>%
  dplyr::ungroup()                                       # Unecessary b/c of `summarize()`, but I like the habit.
ds_month_oklahoma

# The SQL equivalent to the previous dplyr code.
#   SELECT month, county_id, SUM(fte) as fte, 'FALSE' AS fte_approximated
#   FROM ds_nurse_month_oklahoma
#   GROUP BY month, county_id

# The un-piped equivalent to the previous dplyr code.  Notice 3 layers of nesting instead of 3 pipes.
#   ds_month_oklahoma <- dplyr::ungroup(
#     dplyr::summarize(
#       dplyr::group_by(
#         ds_nurse_month_oklahoma,
#         county_id,
#         month
#       ),
#       # Aggregate/summarize within sub-datasets
#       fte               = sum(fte, na.rm=T),
#       # fmla_hours       = sum(fmla_hours, na.rm=T)
#       fte_approximated   = FALSE                            # This variable helps the later union query.
#     )
#   )

rm(ds_nurse_month_oklahoma) #Remove this dataset so it's not accidentally used below.

# ---- groom-tulsa -------------------------------------------------------------
# Groom the nurse-month dataset for Tulsa County.
ds_month_tulsa <- ds_month_tulsa %>%
  dplyr::rename_(
    "month"         = "Month"
    , "fte"         = "FteSum"
    #, "fmla_hours" = "FmlaSum"
  ) %>%
  dplyr::mutate(
    county_id           = ds_county[ds_county$county_name=="Tulsa", ]$county_id,  #Dynamically determine county ID
    month               = as.Date(month, "%m/%d/%Y"),
    #fmla_hours         = ifelse(!is.na(fmla_hours), fmla_hours, 0.0)
    fte_approximated    = FALSE
  )  %>%
  dplyr::select(county_id, month, fte, fte_approximated)
ds_month_tulsa

# ---- groom-rural -------------------------------------------------------------
# Groom the nurse-month dataset for the 75 rural counties.
ds_nurse_month_rural <- ds_nurse_month_rural %>%
  dplyr::rename_(
    "name_full"            = "Name"
    , "county_name"        = "HOME_COUNTY"
    , "region_id"          = "REGIONID"
    , "fte_percent"        = "FTE"
    , "month"              = "PERIOD"
  ) %>%
  dplyr::select(
    county_name,
    month,
    name_full,
    fte_percent
  ) %>% # dplyr::select(name_full, month, county_name, fte_percent) %>%
  dplyr::filter(!(county_name %in% counties_to_drop_from_rural)) %>%
  dplyr::mutate(
    month       = as.Date(paste0(month, "-", default_day_of_month), format="%m/%Y-%d"),
    fte_string  = gsub("^(\\d{1,3})\\s*%$", "\\1", fte_percent),
    fte         = .01 * as.numeric(ifelse(nchar(fte_string)==0L, 0, fte_string)),
    county_name = car::recode(county_name, "'Cimmarron'='Cimarron';'Leflore'='Le Flore'") #Or consider `plyr::recode()`.
  ) %>%
  dplyr::arrange(county_name, month, name_full) %>%
  dplyr::select(
    -fte_percent,
    -fte_string
  ) %>%
  dplyr::left_join(
    ds_county[, c("county_id", "county_name")], by="county_name"
  )
ds_nurse_month_rural

# table(ds_nurse_month_rural$county_id, useNA="always")
# table(ds_nurse_month_rural$county_name, useNA="always")

# Collapse across nurses to create one record per month per county.
ds_month_rural <- ds_nurse_month_rural %>%
  dplyr::group_by(county_id, month) %>%
  dplyr::summarize(
    fte                 = sum(fte, na.rm=TRUE),
    # fmla_hours        = sum(fmla_hours, na.rm=TRUE)
    fte_approximated    = FALSE
  ) %>%
  dplyr::ungroup()
ds_month_rural

possible_months <- seq.Date(range(ds_month_rural$month)[1], range(ds_month_rural$month)[2], by="month")
ds_possible <- expand.grid(month=possible_months, county_id=possible_county_ids, stringsAsFactors=F)
#Consider replacing a join with ds_possible with a call to tidyr::complete().

#Determine the months were we don't have any rural T&E data.
months_rural_not_collected <- (ds_month_rural %>%
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) %>%
  dplyr::group_by(month) %>%
  dplyr::summarize(
    mean_na = mean(is.na(fte))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(mean_na >= .9999))$month
months_rural_not_collected

rm(ds_nurse_month_rural) #Remove this dataset so it's not accidentally used below.
rm(counties_to_drop_from_rural, default_day_of_month)

# ---- union-all-counties -----------------------------------------------------
# Stack the three datasets on top of each other.
ds <- ds_month_oklahoma %>%
  dplyr::union(
    ds_month_tulsa
  ) %>%
  dplyr::union(
    ds_month_rural
  ) %>%
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) %>%
  dplyr::left_join(
    ds_county, by="county_id"
  ) %>%
  dplyr::arrange(county_id, month) %>%
  dplyr::mutate(
    county_month_id             = seq_len(n()), # Add the primary key
    fte                         = ifelse(is.na(fte), 0, fte),
    month_missing               = is.na(fte_approximated),
    fte_approximated            = month_missing & (month %in% months_rural_not_collected),
    fte_rolling_median_11_month = zoo::rollmedian(x=fte, 11, na.pad=T, align="right")
  ) %>%
  dplyr::group_by(county_id) %>%               # Group by county.
  dplyr::mutate(
    county_any_missing  = any(month_missing)     # Determine if a county is missing any month
  ) %>%
  dplyr::ungroup()
ds

#Loop through each county to determine which (if any) months need to be approximated.
#   The dataset is small enough that it's not worth vectorizing.
for( id in sort(unique(ds$county_id)) ) {# for( id in 13 ) {}
  ds_county <- dplyr::filter(ds, county_id==id)
  missing   <- ds_county$fte_approximated #is.na(ds_county$fte_approximated)

  # Attempt to fill in values only for counties missing something.
  if( any(ds_county$county_any_missing) ) {

    #This statement interpolates missing FTE values
    ds_county$fte[missing] <- as.numeric(approx(
      x    = ds_county$month[!missing],
      y    = ds_county$fte[  !missing],
      xout = ds_county$month[ missing]
    )$y)

    #This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if( mean(ds_county$fte, na.rm=T) >= threshold_mean_fte_t_fill_in ) {
      ds_county$fte_approximated <- (ds_county$fte==0)
      ds_county$fte <- ifelse(ds_county$fte==0, ds_county$fte_rolling_median_11_month, ds_county$fte)
    }

    #Overwrite selected values in the real dataset
    ds[ds$county_id==id, ]$fte              <- ds_county$fte
    ds[ds$county_id==id, ]$fte_approximated <- ds_county$fte_approximated
  }
}
ds

rm(ds_month_oklahoma, ds_month_tulsa, ds_month_rural, ds_possible)  #Remove these datasets so it's not accidentally used below.
rm(possible_months, possible_county_ids)

# ---- verify-values -----------------------------------------------------------
# Sniff out problems
testit::assert("The month value must be nonmissing & since 2000", all(!is.na(ds$month) & (ds$month>="2012-01-01")))
testit::assert("The county_id value must be nonmissing & positive.", all(!is.na(ds$county_id) & (ds$county_id>0)))
testit::assert("The county_id value must be in [1, 77].", all(ds$county_id %in% seq_len(77L)))
testit::assert("The region_id value must be nonmissing & positive.", all(!is.na(ds$region_id) & (ds$region_id>0)))
testit::assert("The region_id value must be in [1, 20].", all(ds$region_id %in% seq_len(20L)))
testit::assert("The `fte` value must be nonmissing & positive.", all(!is.na(ds$fte) & (ds$fte>=0)))
# testit::assert("The `fmla_hours` value must be nonmissing & nonnegative", all(is.na(ds$fmla_hours) | (ds$fmla_hours>=0)))

testit::assert("The County-month combination should be unique.", all(!duplicated(paste(ds$county_id, ds$month))))
testit::assert("The Region-County-month combination should be unique.", all(!duplicated(paste(ds$region_id, ds$county_id, ds$month))))
table(paste(ds$county_id, ds$month))[table(paste(ds$county_id, ds$month))>1]

# ---- specify-columns-to-upload -----------------------------------------------
columns_to_write <- c( "county_month_id", "county_id", "month", "fte", "fte_approximated", "region_id")
ds_slim <- ds[, columns_to_write]
ds_slim$fte_approximated <- as.integer(ds_slim$fte_approximated)
ds_slim

# # ---- upload-to-db ------------------------------------------------------------
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

# ---- save-to-disk ------------------------------------------------------------
readr::write_csv(ds, path_out_unified)

#Possibly consider writing to sqlite (with RSQLite) if there's no PHI, or a central database if there is PHI.

# ---- inspect, fig.width=10, fig.height=6, fig.path=figure_path -----------------------------------------------------------------
library(ggplot2)

# Graph each county-month
ggplot(ds, aes(x=month, y=fte, group=factor(county_id), color=factor(county_id), shape=fte_approximated, ymin=0)) +
  geom_point(position=position_jitter(height=.05, width=5), size=4, na.rm=T) +
  # geom_text(aes(label=county_month_id)) +
  geom_line(position=position_jitter(height=.1, width=5)) +
  scale_shape_manual(values=c("TRUE"=21, "FALSE"=NA)) +
  theme_light() +
  guides(color = guide_legend(ncol=4, override.aes = list(size=3, alpha = 1))) +
  guides(shape = guide_legend(ncol=2, override.aes = list(size=3, alpha = 1))) +
  labs(title="FTE sum each month (by county)", y="Sum of FTE for County")

# Graph each region-month
ds_region <- ds %>%
  dplyr::group_by(region_id, month) %>%
  dplyr::summarize(
    fte              = sum(fte, na.rm=T),
    fte_approximated = any(fte_approximated)
  ) %>%
  dplyr::ungroup()

last_plot() %+%
  ds_region +
  aes(group=factor(region_id), color=factor(region_id)) +
  labs(title="FTE sum each month (by region)", y="Sum of FTE for Region")

# last_plot() +
#   aes(y=fmla_hours) +
#   labs(title="fmla_hours sum each month (by county)")
