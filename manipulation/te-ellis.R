# knitr::stitch_rmd(script="manipulation/te-ellis.R", output="stitched-output/manipulation/te-ellis.md") # dir.create("stitched-output/manipulation/", recursive=T)
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path

# Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"        )
requireNamespace("tidyr"        )
requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("rlang"        ) # Language constructs, like quosures
requireNamespace("testit"       ) # For asserting conditions meet expected patterns/conditions.
requireNamespace("checkmate"    ) # For asserting conditions meet expected patterns/conditions. # remotes::install_github("mllg/checkmate")
requireNamespace("DBI"          ) # Database-agnostic interface
requireNamespace("RSQLite"      ) # Lightweight database for non-PHI data.
# requireNamespace("odbc"         ) # For communicating with SQL Server over a locally-configured DSN.  Uncomment if you use 'upload-to-db' chunk.
requireNamespace("OuhscMunge"   ) # remotes::install_github(repo="OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
config                         <- config::get()
# path_out_unified               <- config$path_te_county_month
# path_db                        <- config$path_te_database
# Uncomment the lines above and delete the two below if values are stored in 'config.yml'.

path_out_unified               <- "data-public/derived/county-month-te.csv"
path_db                        <- config$path_database
counties_to_drop_from_rural    <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
default_day_of_month           <- 15L      # Summarize each month at its (rough) midpoint.
possible_county_ids            <- 1:77     #There are 77 counties.
threshold_mean_fte_t_fill_in   <- 10L      #Any county averaging over 10 hours can be filled in with its mean.
figure_path                    <- "stitched-output/manipulation/te/"

# URIs of CSV and County lookup table
path_in_oklahoma  <- "data-public/raw/te/nurse-month-oklahoma.csv"
path_in_tulsa     <- "data-public/raw/te/month-tulsa.csv"
path_in_rural     <- "data-public/raw/te/nurse-month-rural.csv"
path_county       <- "data-public/raw/te/county.csv"

columns_to_stack <- c("county_id", "month", "fte", "fte_approximated") # Explicit order of columns to stack.

# Execute to specify the column types.  It might require some manual adjustment (eg doubles to integers).
# OuhscMunge::readr_spec_aligned(path_in_oklahoma)
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
ds_nurse_month_oklahoma <- readr::read_csv(path_in_oklahoma   , col_types = col_types_oklahoma)
ds_month_tulsa          <- readr::read_csv(path_in_tulsa      , col_types = col_types_tulsa)
ds_nurse_month_rural    <- readr::read_csv(path_in_rural      , col_types = col_types_rural)
ds_county               <- readr::read_csv(path_county        , col_types = col_types_county)

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
# OuhscMunge::column_rename_headstart(ds_county) # Help write `dplyr::select()` call.
ds_county <-
  ds_county |>
  dplyr::select(    # `dplyr::select()` drops columns not included.
    county_id     = CountyID,
    county_name   = CountyName,
    region_id     = C1LeadNurseRegion,
  )

# ---- groom-oklahoma ----------------------------------------------------------
# Sanitize illegal variable names if desired: colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma))
# OuhscMunge::column_rename_headstart(ds_nurse_month_oklahoma)

# Groom the nurse-month dataset for Oklahoma County.
ds_nurse_month_oklahoma <-
  ds_nurse_month_oklahoma |>
  dplyr::select(    # `dplyr::select()` drops columns not included.
    # employee_number         = `Employee..`,       # Used to be Employee # before sanitizing. Drop b/c unnecessary.
    year                      = Year,
    month                     = Month,
    fte                       = FTE,
    fmla_hours                = FMLA.Hours,         # Used to be FMLA Hours before sanitizing.
    training_hours            = Training.Hours      # Used to be Training Hours before sanitizing.
  ) |>
  dplyr::mutate(
    county_id         = ds_county[ds_county$county_name=="Oklahoma", ]$county_id,        # Dynamically determine county ID.
    month             = as.Date(ISOdate(year, month, default_day_of_month)),             # Combine fields for one date.
    # fmla_hours      = dplyr::if_else(!is.na(fmla_hours), fmla_hours, 0L),              # Set missing values to zero.
    training_hours    = dplyr::coalesce(training_hours, 0L)                              # Set missing values to zero.
    # training_hours  = dplyr::if_else(!is.na(training_hours), training_hours, 0L)       # Set missing values to zero.
  ) |>
  dplyr::select(      # Drop unnecessary variables (ie, defensive programming)
    -year
  )
ds_nurse_month_oklahoma

# Collapse across nurses to create one record per month for Oklahoma County.
ds_month_oklahoma <-
  ds_nurse_month_oklahoma |>
  dplyr::group_by(county_id, month) |>                  # Split by County & month into sub-datasets
  dplyr::summarize(                                      # Aggregate/summarize within sub-datasets
    fte                = sum(fte, na.rm=TRUE),
    # fmla_hours       = sum(fmla_hours, na.rm=T)
    fte_approximated   = FALSE,                          # This variable helps the later union query.
  ) |>
  dplyr::ungroup() |>                                   # Unnecessary b/c of `summarize()`, but I like the habit.
  dplyr::select(!!columns_to_stack)                      # Ensure that all three datasets have the same columns and their order is consistent.
ds_month_oklahoma

# The SQL equivalent to the previous dplyr code.
#   SELECT month, county_id, SUM(fte) as fte, 'FALSE' as fte_approximated
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
ds_month_tulsa <-
  ds_month_tulsa |>
  dplyr::select(    # `dplyr::select()` drops columns not included.
    month             = Month,
    fte               = FteSum,
    fmla_sum          = FmlaSum,
  ) |>
  dplyr::mutate(
    county_id           = ds_county[ds_county$county_name=="Tulsa", ]$county_id,  # Dynamically determine county ID
    # fmla_hours        = dplyr::if_else(!is.na(fmla_hours), fmla_hours, 0.0)
    fte_approximated    = FALSE,
  ) |>
  dplyr::select(!!columns_to_stack)                      # Ensure that all three datasets have the same columns and their order is consistent.
ds_month_tulsa

# ---- groom-rural -------------------------------------------------------------
# Groom the nurse-month dataset for the 75 rural counties.
# OuhscMunge::column_rename_headstart(ds_nurse_month_rural)
ds_nurse_month_rural <-
  ds_nurse_month_rural |>
  dplyr::select(    # `dplyr::select()` drops columns not included.
    county_name             = HOME_COUNTY,
    month                   = PERIOD,
    name_full               = Name,
    fte_percent             = FTE
    # employee_id           = EMPLOYEEID    # Not needed
    # region_id             = REGIONID      # Not needed
  ) |>
  dplyr::filter(!(county_name %in% counties_to_drop_from_rural)) |>
  dplyr::mutate(
    month       = as.Date(paste0(month, "-", default_day_of_month), format="%m/%Y-%d"),
    fte_string  = sub("^(\\d{1,3})\\s*%$", "\\1", fte_percent),                            # Extract digits before the '%' sign.
    fte         = .01 * dplyr::if_else(nchar(fte_string)==0L, 0, as.numeric(fte_string)),
    county_name = dplyr::recode(county_name, `Cimmarron`="Cimarron", `Leflore`="Le Flore"),
  ) |>
  dplyr::arrange(county_name, month, name_full) |>
  dplyr::select(
    -fte_percent,
    -fte_string,
  ) |>
  dplyr::left_join(
    ds_county |>
      dplyr::select(
        county_id,
        county_name,
      ),
    by = "county_name"
  )
ds_nurse_month_rural

# table(ds_nurse_month_rural$county_id, useNA="always")
# table(ds_nurse_month_rural$county_name, useNA="always")

# Collapse across nurses to create one record per month per county.
ds_month_rural <-
  ds_nurse_month_rural |>
  dplyr::group_by(county_id, month) |>
  dplyr::summarize(
    fte                 = sum(fte, na.rm=TRUE),
    # fmla_hours        = sum(fmla_hours, na.rm=TRUE),
    fte_approximated    = FALSE,
  ) |>
  dplyr::ungroup() |>
  dplyr::select(!!columns_to_stack)                      # Ensure that all three datasets have the same columns and their order is consistent.
ds_month_rural

# Consider replacing a join with ds_possible with a call to tidyr::complete(), if you can guarantee each month shows up at least once.
ds_possible <-
  tidyr::crossing(
    month     = seq.Date(range(ds_month_rural$month)[1], range(ds_month_rural$month)[2], by="month"),
    county_id = possible_county_ids
  )

# Determine the months were we don't have any rural T&E data.
months_rural_not_collected <-
  ds_month_rural |>
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) |>
  dplyr::group_by(month) |>
  dplyr::summarize(
    mean_na = mean(is.na(fte)),
  ) |>
  dplyr::ungroup() |>
  dplyr::filter(mean_na >= .9999) |>
  dplyr::pull(month)
months_rural_not_collected

rm(ds_nurse_month_rural) #Remove this dataset so it's not accidentally used below.
rm(counties_to_drop_from_rural, default_day_of_month)

# ---- union-all-counties -----------------------------------------------------
# Stack the three datasets on top of each other.
ds <-
  ds_month_oklahoma |>
  dplyr::union_all(ds_month_tulsa) |>
  dplyr::union_all(ds_month_rural) |>
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) |>
  dplyr::left_join(
    ds_county, by="county_id"
  ) |>
  dplyr::arrange(county_id, month) |>
  tibble::rowid_to_column("county_month_id") |>  # Add the primary key
  dplyr::mutate(
    fte                         = dplyr::coalesce(fte, 0),
    month_missing               = is.na(fte_approximated),
    fte_approximated            = month_missing & (month %in% months_rural_not_collected),
    fte_rolling_median_11_month = zoo::rollmedian(x=fte, 11, na.pad=TRUE, align="right"),
  ) |>
  dplyr::group_by(county_id) |>                # Group by county.
  dplyr::mutate(
    county_any_missing  = any(month_missing),   # Determine if a county is missing any month
  ) |>
  dplyr::ungroup()
ds

# Loop through each county to determine which (if any) months need to be approximated.
#   The dataset is small enough that it's not worth vectorizing.
for (id in sort(unique(ds$county_id))) {# for( id in 13 ) {}
  ds_county_approx <- dplyr::filter(ds, county_id==id)
  missing          <- ds_county_approx$fte_approximated #is.na(ds_county_approx$fte_approximated)

  # Attempt to fill in values only for counties missing something.
  if (any(ds_county_approx$county_any_missing)) {

    # This statement interpolates missing FTE values
    ds_county_approx$fte[missing] <- as.numeric(approx(
      x    = ds_county_approx$month[!missing],
      y    = ds_county_approx$fte[  !missing],
      xout = ds_county_approx$month[ missing]
    )$y)

    # This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if (mean(ds_county_approx$fte, na.rm = TRUE) >= threshold_mean_fte_t_fill_in) {
      ds_county_approx$fte_approximated <- (ds_county_approx$fte == 0)
      ds_county_approx$fte              <- dplyr::if_else(ds_county_approx$fte==0, ds_county_approx$fte_rolling_median_11_month, ds_county_approx$fte)
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
checkmate::assert_integer(  ds$county_month_id             , any.missing=F , lower=1, upper=3080                , unique=T)
checkmate::assert_integer(  ds$county_id                   , any.missing=F , lower=1, upper=77                            )
checkmate::assert_date(     ds$month                       , any.missing=F , lower=as.Date("2012-06-15"), upper=Sys.Date())
checkmate::assert_character(ds$county_name                 , any.missing=F , pattern="^.{3,12}$"                          )
checkmate::assert_integer(  ds$region_id                   , any.missing=F , lower=1, upper=20                            )
checkmate::assert_numeric(  ds$fte                         , any.missing=F , lower=0, upper=40                            )
checkmate::assert_logical(  ds$fte_approximated            , any.missing=F                                                )
checkmate::assert_numeric(  ds$fte_rolling_median_11_month , any.missing=T , lower=0, upper=40                            )
checkmate::assert_logical(  ds$month_missing               , any.missing=F                                                )
checkmate::assert_logical(  ds$county_any_missing          , any.missing=F                                                )


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


# Alternative ways to test & diagnose unique combinations.
# testit::assert("The County-month combination should be unique.", all(!duplicated(paste(ds$county_id, ds$month))))
# testit::assert("The Region-County-month combination should be unique.", all(!duplicated(paste(ds$region_id, ds$county_id, ds$month))))
# table(paste(ds$county_id, ds$month))[table(paste(ds$county_id, ds$month))>1]

# ---- specify-columns-to-write ------------------------------------------------
# Print colnames that `dplyr::select()`  should contain below:
#   cat(paste0("    ", colnames(ds), collapse=",\n"))

# Define the subset of columns that will be needed in the analyses.
#   The fewer columns that are exported, the fewer things that can break downstream.
ds_slim <-
  ds |>
  # dplyr::slice(1:100) |>
  dplyr::select(
    county_month_id,
    county_id,
    month,
    fte,
    fte_approximated,
    region_id,
  ) |>
  dplyr::mutate_if(is.logical, as.integer)       # Some databases & drivers need 0/1 instead of FALSE/TRUE.
ds_slim

# ---- save-to-disk ------------------------------------------------------------
# If there's *NO* PHI, a rectangular CSV is usually adequate, and it's portable to other machines and software.
readr::write_csv(ds_slim, path_out_unified)
# readr::write_rds(ds_slim, path_out_unified, compress="gz") # Save as a compressed R-binary file if it's large or has a lot of factors.

# ---- save-to-db --------------------------------------------------------------
# If there's *NO* PHI, a local database like SQLite fits a nice niche if
#   * the data is relational and
#   * later, only portions need to be queried/retrieved at a time (b/c everything won't need to be loaded into R's memory)
# SQLite data types work differently than most databases: https://www.sqlite.org/datatype3.html#type_affinity

sql_create <- c(
  "
    DROP TABLE IF EXISTS county;
  ",
  "
    CREATE TABLE `county` (
      county_id              integer     not null primary key,
      county_name            varchar(15) not null,
      region_id              integer     not null
    );
  ",
  "
    DROP TABLE IF EXISTS te_month;
  ",
  "
    CREATE TABLE `te_month` (
      county_month_id                    integer     not null primary key,
      county_id                          integer     not null,
      month                              date        not null,         -- there's no date type in sqlite.  make sure it's iso8601: yyyy-mm-dd
      fte                                real        not null,
      fte_approximated                   boolean     not null,
      month_missing                      integer     not null,         -- there's no bit/boolean type in sqlite
      fte_rolling_median_11_month        integer

      -- FOREIGN KEY(county_id) REFERENCES county(county_id)
    );
  "
)
# Remove old DB
# if( file.exists(path_db) ) file.remove(path_db)

# Create directory if necessary.
if (fs::dir_exists(fs::path_dir(path_db)))
  fs::dir_create(fs::path_dir(path_db))

# Open connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
# result <- DBI::dbSendQuery(cnn, "PRAGMA foreign_keys=ON;") #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
# DBI::dbClearResult(result)
DBI::dbListTables(cnn)

# Create tables
sql_create |>
  purrr::walk(~DBI::dbExecute(cnn, .))
DBI::dbListTables(cnn)

# Write to database
DBI::dbWriteTable(cnn, name = "county", value = ds_county, append = TRUE, row.names = FALSE)
ds |>
  dplyr::mutate(
    month               = strftime(month, "%Y-%m-%d"),
    fte_approximated    = as.logical(fte_approximated),
    month_missing       = as.logical(month_missing),
  ) |>
  dplyr::select(county_month_id, county_id, month, fte, fte_approximated, month_missing, fte_rolling_median_11_month) |>
  DBI::dbWriteTable(conn=cnn, name = "te_month", append = TRUE, row.names = FALSE)

# Allow database to optimize its internal arrangement
DBI::dbExecute(cnn, "VACUUM;")

# Close connection
DBI::dbDisconnect(cnn)


# # ---- save-to-db-alternatives -------------------------------------------------
# If there *IS* PHI, write to a central database server that authenticates users (like SQL Server).
#   There are three options below, in descending order of our preference.

# Option 1: this single function uploads to a SQL Server database.
# OuhscMunge::upload_sqls_odbc(
#   d             = ds_slim,
#   schema_name   = "osdh",
#   table_name    = "te",
#   dsn_name      = "te-example", # Or config$dsn_te,
#   timezone      = config$time_zone_local, # Uncomment if uploading non-UTC datetimes
#   clear_table   = T,
#   create_table  = F,
#   convert_logical_to_integer = T
# ) # 0.012 minutes

# Option 2: use the DBI-compliant 'odbc' package.
# (startTime <- Sys.time())
# dbTable <- "Osdh.tblC1TEMonth"
# cnn <- DBI::dbConnect(drv=odbc::odbc(), dsn="te-example")
# DBI::dbGetInfo(cnn)
# table_id <- DBI::Id(schema="osdh", table="te")
# table_id <- DBI::Id(table="te")                  # If the schema name is `dbo`.
#
# DBI::dbWriteTable(
#   conn        = cnn,
#   name        = table_id,
#   value       = ds_slim,
#   overwrite   = overwrite,
#   append      = append
# )
# DBI::dbDisconnect(cnn)
# (elapsedDuration <-  Sys.time() - startTime) #21.4032 secs 2015-10-31

# ---- inspect, fig.width=10, fig.height=6, fig.path=figure_path -----------------------------------------------------------------
# This last section is kinda cheating, and should belong in an 'analysis' file, not a 'manipulation' file.
