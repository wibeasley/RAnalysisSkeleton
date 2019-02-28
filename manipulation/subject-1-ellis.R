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
  county_id           = readr::col_integer(),
  gender_id           = readr::col_double(),
  race                = readr::col_character(),
  ethnicity           = readr::col_character()
)

# ---- load-data ---------------------------------------------------------------
# Read the CSVs
# readr::spec_csv(config$path_subject_1_raw)
ds <- readr::read_csv(config$path_subject_1_raw  , col_types=col_types)

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
    "county_id",
    "gender_id",
    "race",
    "ethnicity"
  )) %>%
  dplyr::mutate(

  )  %>%
  dplyr::arrange(subject_id)

# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds)
checkmate::assert_integer(  ds$subject_id , any.missing=F , lower=1001, upper=1200 , unique=T)
checkmate::assert_integer(  ds$county_id  , any.missing=F , lower=1, upper=77     )
checkmate::assert_numeric(  ds$gender_id  , any.missing=F , lower=1, upper=255     )
checkmate::assert_character(ds$race       , any.missing=F , pattern="^.{5,41}$"    )
checkmate::assert_character(ds$ethnicity  , any.missing=F , pattern="^.{18,30}$"   )

# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds)) # Print colnames for line below.
columns_to_write <- c(
  "subject_id",
  "county_id",
  "gender_id",
  "race",
  "ethnicity"
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
  "
    DROP TABLE IF EXISTS subject;
  ",
  "
    CREATE TABLE `subject` (
      subject_id              INT NOT NULL PRIMARY KEY,
      county_id               INT NOT NULL,
      gender_id               FLOAT NOT NULL,
      race                    FLOAT NOT NULL,
      ethnicity               FLOAT NOT NULL
    );
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
DBI::dbWriteTable(cnn, name='subject',            value=ds_slim,        append=TRUE, row.names=FALSE)

# Close connection
DBI::dbDisconnect(cnn)
