# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./stitched-output/manipulation/te-ellis.md") # dir.create("./stitched-output/manipulation/", recursive=T)
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these package(s) so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr            , quietly=TRUE)
library(DBI                 , quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"        )
requireNamespace("tidyr"        )
requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"       ) # For asserting conditions meet expected patterns/conditions.
requireNamespace("checkmate"    ) # For asserting conditions meet expected patterns/conditions. # remotes::install_github("mllg/checkmate")
requireNamespace("RSQLite"      ) # Lightweight database for non-PHI data.
# requireNamespace("RODBC"      ) # For communicating with SQL Server over a locally-configured DSN.  Uncomment if you use 'upload-to-db' chunk.
requireNamespace("OuhscMunge"   ) # remotes::install_github(repo="OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
path_out_unified               <- "data-public/derived/county-month-te.csv"
path_db                        <- "data-unshared/derived/te.sqlite3"
counties_to_drop_from_rural    <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
default_day_of_month           <- 15L      # Summarize each month at its (rough) midpoint.
possible_county_ids            <- 1:77     #There are 77 counties.
threshold_mean_fte_t_fill_in   <- 10L      #Any county averaging over 10 hours can be filled in with its mean.
figure_path <- 'stitched-output/manipulation/te/'

# URIs of CSV and County lookup table
path_in_oklahoma  <- "./data-public/raw/te/nurse-month-oklahoma.csv"
path_in_tulsa     <- "./data-public/raw/te/month-tulsa.csv"
path_in_rural     <- "./data-public/raw/te/nurse-month-rural.csv"
path_county       <- "./data-public/raw/te/county.csv"

col_types_oklahoma <- readr::cols_only( # readr::spec_csv(path_in_oklahoma)
  `Employee..`          = readr::col_integer(),
  `Year`                = readr::col_integer(),
  `Month`               = readr::col_integer(),
  `FTE`                 = readr::col_double(),
  `FMLA.Hours`          = readr::col_integer(),
  `Training.Hours`      = readr::col_integer(),
  `Name`                = readr::col_character()
)

col_types_tulsa <- readr::cols_only( # readr::spec_csv(path_in_tulsa)
  Month                 = readr::col_date("%m/%d/%Y"),
  FteSum                = readr::col_double(),
  FmlaSum               = readr::col_integer()
)

col_types_rural <- readr::cols_only( # readr::spec_csv(path_in_rural)
  HOME_COUNTY           = readr::col_character(),
  FTE                   = readr::col_character(),  # Force as a character.
  PERIOD                = readr::col_character(),
  EMPLOYEEID            = readr::col_integer(),
  REGIONID              = readr::col_integer(),
  Name                  = readr::col_character()
)

col_types_county <- readr::cols_only( # readr::spec_csv(path_county)
  CountyID              = readr::col_integer(),
  CountyName            = readr::col_character(),
  GeoID                 = readr::col_integer(),
  FipsCode              = readr::col_integer(),
  FundingC1             = readr::col_integer(),
  FundingOcap           = readr::col_integer(),
  C1LeadNurseRegion     = readr::col_integer(),
  C1LeadNurseName       = readr::col_character(),
  Urban                 = readr::col_integer(),
  LabelLongitude        = readr::col_double(),
  LabelLatitude         = readr::col_double(),
  MiechvEvaluation      = readr::col_integer(),
  MiechvFormula         = readr::col_integer()
)

# ---- load-data ---------------------------------------------------------------
# Read the CSVs
ds_nurse_month_oklahoma <- readr::read_csv(path_in_oklahoma   , col_types=col_types_oklahoma)
ds_month_tulsa          <- readr::read_csv(path_in_tulsa      , col_types=col_types_tulsa)
ds_nurse_month_rural    <- readr::read_csv(path_in_rural      , col_types=col_types_rural)
ds_county               <- readr::read_csv(path_county        , col_types=col_types_county)

rm(path_in_oklahoma, path_in_tulsa, path_in_rural, path_county)
rm(col_types_oklahoma, col_types_tulsa, col_types_rural, col_types_county)

# Print the first few rows of each table, especially if you're stitching with knitr (see first line of this file).
#   If you print, make sure that the datasets don't contain any PHI.
#   A normal `data.frame` will print all rows.  But `readr::read_csv()` returns a `tibble::tibble`,
#   which prints only the first 10 rows by default.  It also lists the data type of each column.
ds_nurse_month_oklahoma
ds_month_tulsa
ds_nurse_month_rural
ds_county

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_county) #Spit out columns to help write call ato `dplyr::rename()`.
ds_county <- ds_county %>%
  dplyr::select_( #`select()` implicitly drops the other columns not mentioned.
    "county_id"     = "CountyID",
    "county_name"   = "CountyName",
    "region_id"     = "C1LeadNurseRegion"
  )

# ---- groom-oklahoma ----------------------------------------------------------
# Sanitize illegal variable names if desired: colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma))
# OuhscMunge::column_rename_headstart(ds_nurse_month_oklahoma)

# Groom the nurse-month dataset for Oklahoma County.
ds_nurse_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::select_(
    # "employee_number"           = "`Employee..`"          # Used to be "Employee #" before sanitizing. Drop b/c unnecessary.
    # , "employee_name"           = "`Name`"
    "year"                        = "`Year`"
    , "month"                     = "`Month`"
    , "fte"                       = "`FTE`"
    , "fmla_hours"                = "`FMLA.Hours`"          # Used to be "FMLA Hours" before sanitizing.
    , "training_hours"            = "`Training.Hours`"      # Used to be "Training Hours" before sanitizing.
  ) %>%
  dplyr::mutate(
    county_id         = ds_county[ds_county$county_name=="Oklahoma", ]$county_id,        # Dynamically determine county ID.
    month             = as.Date(ISOdate(year, month, default_day_of_month)),             # Combine fields for one date.
    # fmla_hours      = dplyr::if_else(!is.na(fmla_hours), fmla_hours, 0L),              # Set missing values to zero.
    training_hours    = dplyr::coalesce(training_hours, 0L)                              # Set missing values to zero.
    # training_hours  = dplyr::if_else(!is.na(training_hours), training_hours, 0L)       # Set missing values to zero.
  ) %>%
  dplyr::select(      # Drop unecessary variables (ie, defensive programming)
    -year
  )
ds_nurse_month_oklahoma

# Collapse across nurses to create one record per month for Oklahoma County.
ds_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::group_by(county_id, month) %>%                  # Split by County & month into sub-datasets
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
# OuhscMunge::column_rename_headstart(ds_month_tulsa)
ds_month_tulsa <- ds_month_tulsa %>%
  dplyr::select_(
    "month"             = "`Month`"
    , "fte"             = "`FteSum`"
    , "fmla_sum"        = "`FmlaSum`"
  ) %>%
  dplyr::mutate(
    county_id           = ds_county[ds_county$county_name=="Tulsa", ]$county_id,  #Dynamically determine county ID
    #fmla_hours         = ifelse(!is.na(fmla_hours), fmla_hours, 0.0)
    fte_approximated    = FALSE
  )  %>%
  dplyr::select(county_id, month, fte, fte_approximated)
ds_month_tulsa

# ---- groom-rural -------------------------------------------------------------
# Groom the nurse-month dataset for the 75 rural counties.
OuhscMunge::column_rename_headstart(ds_nurse_month_rural)
ds_nurse_month_rural <- ds_nurse_month_rural %>%
  dplyr::select_(
    "name_full"                 = "`Name`"
    , "county_name"             = "`HOME_COUNTY`"
    , "fte_percent"             = "`FTE`"
    , "month"                   = "`PERIOD`"
    # , "employee_id"           = "`EMPLOYEEID`"    # Not needed
    # , "region_id              = "`REGIONID`"      # Not needed
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
    fte_string  = gsub("^(\\d{1,3})\\s*%$", "\\1", fte_percent),                           # Extract digits before the '%' sign.
    fte         = .01 * as.numeric(ifelse(nchar(fte_string)==0L, 0, fte_string)),
    county_name = dplyr::recode(county_name, `Cimmarron`='Cimarron', `Leflore`='Le Flore') # Or consider `car::recode()`.
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

# Consider replacing a join with ds_possible with a call to tidyr::complete(), if you can guarantee each month shows up at least once.
ds_possible <- tidyr::crossing(
  month     = seq.Date(range(ds_month_rural$month)[1], range(ds_month_rural$month)[2], by="month"),
  county_id = possible_county_ids
)

# Determine the months were we don't have any rural T&E data.
months_rural_not_collected <- ds_month_rural %>%
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) %>%
  dplyr::group_by(month) %>%
  dplyr::summarize(
    mean_na = mean(is.na(fte))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(mean_na >= .9999) %>%
  dplyr::pull(month)
months_rural_not_collected

rm(ds_nurse_month_rural) #Remove this dataset so it's not accidentally used below.
rm(counties_to_drop_from_rural, default_day_of_month)

# ---- union-all-counties -----------------------------------------------------
# Stack the three datasets on top of each other.
ds <- ds_month_oklahoma %>%
  dplyr::union(ds_month_tulsa) %>%
  dplyr::union(ds_month_rural) %>%
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) %>%
  dplyr::left_join(
    ds_county, by="county_id"
  ) %>%
  dplyr::arrange(county_id, month) %>%
  dplyr::mutate(
    county_month_id             = seq_len(n()), # Add the primary key
    fte                         = dplyr::coalesce(fte, 0),
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
  ds_county_approx <- dplyr::filter(ds, county_id==id)
  missing          <- ds_county_approx$fte_approximated #is.na(ds_county_approx$fte_approximated)

  # Attempt to fill in values only for counties missing something.
  if( any(ds_county_approx$county_any_missing) ) {

    # This statement interpolates missing FTE values
    ds_county_approx$fte[missing] <- as.numeric(approx(
      x    = ds_county_approx$month[!missing],
      y    = ds_county_approx$fte[  !missing],
      xout = ds_county_approx$month[ missing]
    )$y)

    # This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if( mean(ds_county_approx$fte, na.rm=T) >= threshold_mean_fte_t_fill_in ) {
      ds_county_approx$fte_approximated <- (ds_county_approx$fte==0)
      ds_county_approx$fte              <- ifelse(ds_county_approx$fte==0, ds_county_approx$fte_rolling_median_11_month, ds_county_approx$fte)
    }

    # Overwrite selected values in the real dataset
    ds[ds$county_id==id, ]$fte              <- ds_county_approx$fte
    ds[ds$county_id==id, ]$fte_approximated <- ds_county_approx$fte_approximated
  }
}
ds

rm(ds_month_oklahoma, ds_month_tulsa, ds_month_rural, ds_possible)  #Remove these datasets so it's not accidentally used below.
rm(possible_county_ids)

# ---- verify-values -----------------------------------------------------------
# Sniff out problems
# OuhscMunge::verify_value_headstart(ds)
checkmate::assert_integer(ds$county_month_id    , lower=          1L              , any.missing=F, unique=T)
checkmate::assert_integer(ds$county_id          , lower=          1L   , upper=77L, any.missing=F, unique=F)
checkmate::assert_date(   ds$month              , lower="2012-01-01"              , any.missing=F)
checkmate::assert_integer(ds$region_id          , lower=          1L   , upper=20L, any.missing=F)
checkmate::assert_numeric(ds$fte                , lower=          0    , upper=40L, any.missing=F)
checkmate::assert_logical(ds$fte_approximated                                     , any.missing=F)

county_month_combo   <- paste(ds$county_id, ds$month)
# Light way to test combination
checkmate::assert_character(county_month_combo, min.chars=8            , any.missing=F, unique=T)
# Vigilant way to test combination
checkmate::assert_character(county_month_combo, pattern  ="^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$"            , any.missing=F, unique=T)

# # Two ways to diagnose/identify bad patterns
# which(!grepl("^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", county_month_combo))                  # Ideally this is an empty set (ie, `integer(0)`)
# county_month_combo[!grepl("^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", county_month_combo)]     # Ideally this is an empty set (ie, `chracter(0)`)
#
# # Two ways to diagnose/identify bad patterns duplicates
# which(duplicated(county_month_combo))                                                 # Ideally this is an empty set (ie, `integer(0)`)
# county_month_combo[!grepl("^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", county_month_combo)]     # Ideally this is an empty set (ie, `chracter(0)`)


# Alternative ways to test & diagnose unique combintations.
# testit::assert("The County-month combination should be unique.", all(!duplicated(paste(ds$county_id, ds$month))))
# testit::assert("The Region-County-month combination should be unique.", all(!duplicated(paste(ds$region_id, ds$county_id, ds$month))))
# table(paste(ds$county_id, ds$month))[table(paste(ds$county_id, ds$month))>1]

# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds)) # Print colnames for line below.
columns_to_write <- c(
  "county_month_id", "county_id",
  "month", "fte", "fte_approximated",
  "region_id"
)
ds_slim <- ds %>%
  dplyr::select_(.dots=columns_to_write) %>%
  # dplyr::slice(1:100) %>%
  dplyr::mutate(
    fte_approximated <- as.integer(fte_approximated)
  )
ds_slim

rm(columns_to_write)

# ---- save-to-disk ------------------------------------------------------------
# If there's no PHI, a rectangular CSV is usually adequate, and it's portable to other machines and software.
readr::write_csv(ds, path_out_unified)
# readr::write_rds(ds, path_out_unified, compress="gz") # Save as a compressed R-binary file if it's large or has a lot of factors.


# ---- save-to-db --------------------------------------------------------------
# If there's no PHI, a local database like SQLite fits a nice niche if
#   * the data is relational and
#   * later, only portions need to be queried/retrieved at a time (b/c everything won't need to be loaded into R's memory)

sql_create_tbl_county <- "
  CREATE TABLE `tbl_county` (
  	county_id              INTEGER NOT NULL PRIMARY KEY,
    county_name            VARCHAR NOT NULL,
    region_id              INTEGER NOT NULL
  );"

sql_create_tbl_te_month <- "
  CREATE TABLE `tbl_te_month` (
  	county_month_id                    INTEGER NOT NULL PRIMARY KEY,
  	county_id                          INTEGER NOT NULL,
    month                              VARCHAR NOT NULL,         -- There's no date type in SQLite.  Make sure it's ISO8601: yyyy-mm-dd
    fte                                REAL    NOT NULL,
    fte_approximated                   REAL    NOT NULL,
    month_missing                      INTEGER NOT NULL,         -- There's no bit/boolean type in SQLite
    fte_rolling_median_11_month        INTEGER, --  NOT NULL

    FOREIGN KEY(county_id) REFERENCES tbl_county(county_id)
  );"

# Remove old DB
if( file.exists(path_db) ) file.remove(path_db)

# Open connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
RSQLite::dbSendQuery(cnn, "PRAGMA foreign_keys=ON;") #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
dbListTables(cnn)

# Create tables
dbSendQuery(cnn, sql_create_tbl_county)
dbSendQuery(cnn, sql_create_tbl_te_month)
dbListTables(cnn)

# Write to database
dbWriteTable(cnn, name='tbl_county',              value=ds_county,        append=TRUE, row.names=FALSE)
ds %>%
  dplyr::mutate(
    month               = strftime(month, "%Y-%m-%d"),
    fte_approximated    = as.logical(fte_approximated),
    month_missing       = as.logical(month_missing)
  ) %>%
  dplyr::select(county_month_id, county_id, month, fte, fte_approximated, month_missing, fte_rolling_median_11_month) %>%
  dbWriteTable(value=., conn=cnn, name='tbl_te_month', append=TRUE, row.names=FALSE)

# Close connection
dbDisconnect(cnn)

# # ---- upload-to-db ----------------------------------------------------------
# If there's PHI, write to a central database server that authenticates users (like SQL Server).
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


#Possibly consider writing to sqlite (with RSQLite) if there's no PHI, or a central database if there is PHI.

# ---- inspect, fig.width=10, fig.height=6, fig.path=figure_path -----------------------------------------------------------------
# This last section is kinda cheating, and should belong in an 'analysis' file, not a 'manipulation' file.
#   It's included here for the sake of demonstration.

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
