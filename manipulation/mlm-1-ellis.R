# knitr::stitch_rmd(script="manipulation/te-ellis.R", output="stitched-output/manipulation/te-ellis.md") # dir.create("stitched-output/manipulation/", recursive=T)
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these package(s) so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr            , quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"        )
requireNamespace("tidyr"        )
requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("rlang"        ) # Language constucts, like quosures
requireNamespace("testit"       ) # For asserting conditions meet expected patterns/conditions.
requireNamespace("checkmate"    ) # For asserting conditions meet expected patterns/conditions. # remotes::install_github("mllg/checkmate")
requireNamespace("DBI"          ) # Database-agnostic interface
requireNamespace("RSQLite"      ) # Lightweight database for non-PHI data.
# requireNamespace("RODBC"      ) # For communicating with SQL Server over a locally-configured DSN.  Uncomment if you use 'upload-to-db' chunk.
requireNamespace("OuhscMunge"   ) # remotes::install_github(repo="OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
config                         <- config::get()
path_db                        <- config$path_database

figure_path <- 'stitched-output/manipulation/ellis/mlm-1-ellis/'

col_types <- readr::cols_only(
  subject_id          = readr::col_integer(),
  wave_id             = readr::col_integer(),
  # year                = readr::col_integer(),
  age                 = readr::col_integer(),
  date_at_visit       = readr::col_date(),
  county_id           = readr::col_integer(),
  int_factor_1        = readr::col_double(),
  slope_factor_1      = readr::col_double(),
  cog_1               = readr::col_double(),
  cog_2               = readr::col_double(),
  cog_3               = readr::col_double(),
  phys_1              = readr::col_double(),
  phys_2              = readr::col_double(),
  phys_3              = readr::col_double()
)

# ---- load-data ---------------------------------------------------------------
# Read the CSVs
# readr::spec_csv(config$path_mlm_1)
ds <- readr::read_csv(config$path_mlm_1_raw  , col_types=col_types)

rm(col_types)

# Print the first few rows of each table, especially if you're stitching with knitr (see first line of this file).
#   If you print, make sure that the datasets don't contain any PHI.
#   A normal `data.frame` will print all rows.  But `readr::read_csv()` returns a `tibble::tibble`,
#   which prints only the first 10 rows by default.  It also lists the data type of each column.
ds

# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds) #Spit out columns to help write call ato `dplyr::rename()`.
ds <-
  ds %>%
  dplyr::select(!!c( #`select()` implicitly drops the other columns not mentioned.
    "subject_id",
    "wave_id",
    # "year",
    "date_at_visit",
    "age",
    "county_id",
    "int_factor_1",
    "slope_factor_1",
    "cog_1",
    "cog_2",
    "cog_3",
    "phys_1",
    "phys_2",
    "phys_3"
  )) %>%
  dplyr::mutate(
    subject_id  = factor(subject_id),
    year        = as.integer(lubridate::year(date_at_visit)),
    age_cut_4   = cut(age, breaks=c(50, 60, 70, 80, Inf), labels=c("50s", "60s", "70s", "80+"), include.lowest = T),
    age_80_plus = (80L <= age)
  )  %>%
  dplyr::arrange(subject_id, wave_id) %>%
  tibble::rowid_to_column("subject_wave_id")


# ---- isolate-subject ---------------------------------------------------------
ds_subject <-
  ds %>%
  dplyr::select(
    subject_id,
    county_id,
    year,
    age
  ) %>%
  dplyr::distinct(.keep_all = T) %>%
  dplyr::group_by(subject_id) %>%
  dplyr::summarize(
    county_id_count = dplyr::n_distinct(county_id),
    county_id       = OuhscMunge::first_nonmissing(county_id),
    year_min        = min(year, na.rm=T),
    year_max        = max(year, na.rm=T),
    age_min         = min(age, na.rm=T),
    age_max         = max(age, na.rm=T),
  ) %>%
  dplyr::ungroup()


# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds_subject)
checkmate::assert_factor(  ds_subject$subject_id      , any.missing=F                          , unique=T)
checkmate::assert_integer( ds_subject$county_id       , any.missing=F , lower=51, upper=72     )
checkmate::assert_integer( ds_subject$county_id_count , any.missing=F , lower=1       )
checkmate::assert_integer( ds_subject$year_min        , any.missing=F , lower=2000, upper=2005 )
checkmate::assert_integer( ds_subject$year_max        , any.missing=F , lower=2009, upper=2014 )
checkmate::assert_integer( ds_subject$age_min         , any.missing=F , lower=55, upper=75     )
checkmate::assert_integer( ds_subject$age_max         , any.missing=F , lower=55, upper=90     )


# OuhscMunge::verify_value_headstart(ds)
checkmate::assert_integer( ds$subject_wave_id   , any.missing=F , lower=1, upper=200     , unique=T)
checkmate::assert_factor(  ds$subject_id        , any.missing=F                          )
checkmate::assert_integer( ds$wave_id           , any.missing=F , lower=1, upper=10      )
checkmate::assert_integer( ds$year              , any.missing=F , lower=2000, upper=2014 )
checkmate::assert_date(    ds$date_at_visit     , any.missing=F , lower=as.Date("2000-01-01"), upper=as.Date("2018-12-31") )
checkmate::assert_integer( ds$age               , any.missing=F , lower=55, upper=85     )
checkmate::assert_factor(  ds$age_cut_4         , any.missing=F                          )
checkmate::assert_logical( ds$age_80_plus       , any.missing=F                          )
checkmate::assert_integer( ds$county_id         , any.missing=F , lower=1, upper=77      )

checkmate::assert_numeric( ds$cog_1             , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$cog_2             , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$cog_3             , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$phys_1            , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$phys_2            , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$phys_3            , any.missing=F , lower=0, upper=20     )

subject_wave_combo   <- paste(ds$subject_id, ds$wave_id)
# Light way to test combination
checkmate::assert_character(subject_wave_combo, min.chars=3            , any.missing=F, unique=T)
# Vigilant way to test combination
checkmate::assert_character(subject_wave_combo, pattern  ="^\\d{4} \\d{1,2}$"   , any.missing=F, unique=T)

# # Two ways to diagnose/identify bad patterns
which(!grepl("^\\d{1,3} \\d{1,2}$", subject_wave_combo))                  # Ideally this is an empty set (ie, `integer(0)`)
subject_wave_combo[!grepl("^\\d{1,3} \\d{1,2}$", subject_wave_combo)]     # Ideally this is an empty set (ie, `chracter(0)`)

# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds)) # Print colnames for line below.
columns_to_write_subject <- c(
  "subject_id",
  "county_id",
  "county_id_count",
  "year_min",
  "year_max",
  "age_min",
  "age_max"
)
columns_to_write <- c(
  "subject_wave_id", "subject_id",
  "wave_id", "year", "date_at_visit",
  "age", "age_cut_4", "age_80_plus",
  #"county_id",
  "int_factor_1", "slope_factor_1",
  "cog_1", "cog_2", "cog_3",
  "phys_1", "phys_2", "phys_3"
)
ds_slim <-
  ds %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(!!columns_to_write)

ds_slim

rm(columns_to_write)

# ---- save-to-disk ------------------------------------------------------------
# If there's no PHI, a rectangular CSV is usually adequate, and it's portable to other machines and software.
# readr::write_csv(ds_slim, path_out_unified)
# readr::write_rds(ds_slim, path_out_unified, compress="gz") # Save as a compressed R-binary file if it's large or has a lot of factors.


# ---- save-to-db --------------------------------------------------------------
# If there's no PHI, a local database like SQLite fits a nice niche if
#   * the data is relational and
#   * later, only portions need to be queried/retrieved at a time (b/c everything won't need to be loaded into R's memory)
# cat(dput(colnames(ds)), sep = "\n")
sql_create <- c(
  # "
  #   DROP TABLE IF EXISTS subject;
  # ",
  "
    DROP TABLE IF EXISTS mlm_1;
  ",
  # "
  #   CREATE TABLE `subject` (
  #     subject_id              INT NOT NULL PRIMARY KEY,
  #     county_id               INT NOT NULL,
  #     county_id_count         INT NOT NULL,
  #     year_min                FLOAT NOT NULL,
  #     year_max                FLOAT NOT NULL,
  #     age_min                 FLOAT NOT NULL,
  #     age_max                 FLOAT NOT NULL
  #   );
  # ",
  "
    CREATE TABLE mlm_1 (
      subject_wave_id         INT NOT NULL PRIMARY KEY,
      subject_id              INT NOT NULL,
      wave_id                 INT NOT NULL,
      year                    INT NOT NULL,
      date_at_visit           DATE NOT NULL,
      age                     INT NOT NULL,
      age_cut_4               VARCHAR(5) NOT NULL,
      -- county_id               INT NOT NULL,
      age_80_plus             BIT NOT NULL,
      int_factor_1            FLOAT NOT NULL,
      slope_factor_1          FLOAT NOT NULL,
      cog_1                   FLOAT NOT NULL,
      cog_2                   FLOAT NOT NULL,
      cog_3                   FLOAT NOT NULL,
      phys_1                  FLOAT NOT NULL,
      phys_2                  FLOAT NOT NULL,
      phys_3                  FLOAT NOT NULL
    )
  "
)

# Remove old DB
# if( file.exists(path_db) ) file.remove(path_db)

# Open connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
result <- DBI::dbSendQuery(cnn, "PRAGMA foreign_keys=ON;") #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
DBI::dbClearResult(result)
DBI::dbListTables(cnn)

# Create tables
sql_create %>%
  purrr::walk(~DBI::dbExecute(cnn, .))
DBI::dbListTables(cnn)

# Write to database
ds_slim %>%
  # dplyr::mutate_if(is.logical, as.integer) %>%        # Some databases & drivers need 0/1 instead of FALSE/TRUE.
  # dplyr::mutate_if(is.Date, as.character) %>%        # Some databases & drivers need 0/1 instead of FALSE/TRUE.
  dplyr::mutate(
    date_at_visit   = as.character(date_at_visit    )
  ) %>%
  DBI::dbWriteTable(cnn, name='mlm_1',              value=.,        append=TRUE, row.names=FALSE)

# DBI::dbWriteTable(cnn, name='subject',            value=ds_subject,        append=TRUE, row.names=FALSE)

# Close connection
DBI::dbDisconnect(cnn)
