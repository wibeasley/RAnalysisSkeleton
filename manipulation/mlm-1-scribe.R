# knitr::stitch_rmd(script="manipulation/mlm-scribe.R", output="stitched-output/manipulation/mlm-scribe.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
# source("manipulation/osdh/ellis/common-ellis.R")
# base::source(file="Dal/Osdh/Arch/benchmark-client-program-arch.R") #Load retrieve_benchmark_client_program

# ---- load-packages -----------------------------------------------------------
import::from("magrittr", "%>%")
requireNamespace("DBI")
requireNamespace("odbc")
requireNamespace("tibble")
requireNamespace("readr"                      )  # remotes::install_github("tidyverse/readr")
requireNamespace("dplyr"                      )
requireNamespace("checkmate"                  )
requireNamespace("testit"                     )
requireNamespace("config"                     )
requireNamespace("OuhscMunge"                 )   # remotes::install_github("OuhscBbmc/OuhscMunge")
# requireNamespace("RcppRoll")

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
config                         <- config::get()
path_db                        <- config$path_database

sql_event <-
  "
    SELECT
      m.subject_wave_id,
      m.subject_id,
      s.county_id,
      s.gender_id,
      s.race,
      s.ethnicity,
      luc.county_name             as county,
      m.wave_id,
      m.year,
      m.date_at_visit,
      m.age,
      m.age_cut_4,
      m.age_80_plus,
      m.int_factor_1,
      m.slope_factor_1,
      m.cog_1,
      m.cog_2,
      m.cog_3,
      m.phys_1,
      m.phys_2,
      m.phys_3
    FROM mlm_1          as m
      left join subject as s   on   m.subject_id =   s.subject_id
      left join county  as luc on   s.county_id  = luc.county_id
    ORDER BY m.subject_id, m.wave_id
  "

# col_types_capacity <- readr::cols_only(
#   program_code          = readr::col_integer(),
#   program_name_ugly     = readr::col_character(),
#   county_id             = readr::col_integer(),
#   service_capacity_count= readr::col_integer()
# )

# ---- load-data ---------------------------------------------------------------
# ds_lu_program   <- retrieve_program()
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
DBI::dbListTables(cnn)
ds <- DBI::dbGetQuery(cnn, sql_event) #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
DBI::dbDisconnect(cnn); rm(cnn, sql_event)

checkmate::assert_data_frame(ds           , min.rows = 200)

# ---- tweak-data --------------------------------------------------------------
dim(ds)
ds <-
  ds %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    # When reading from SQLite, there are some data types that need to be cast explicitly.  SQL Server and the 'odbc' package handles dates and bits/logicals naturally.
    age_80_plus         = as.logical(age_80_plus),
    date_at_visit       = as.Date(date_at_visit)
  )
dim(ds)

# ---- collapse-to-county ------------------------------------------------------
ds_county <-
  ds %>%
  dplyr::group_by(county_id, county) %>%
  dplyr::summarize(
    cog_1_mean      = mean(cog_1    , na.rm=T),
    cog_2_mean      = mean(cog_2    , na.rm=T),
    cog_3_mean      = mean(cog_3    , na.rm=T),
    phys_1_mean     = mean(phys_1   , na.rm=T),
    phys_2_mean     = mean(phys_2   , na.rm=T),
    phys_3_mean     = mean(phys_3   , na.rm=T)
  ) %>%
  dplyr::ungroup()

# ---- collapse-to-county-year ------------------------------------------------------
ds_county_year <-
  ds %>%
  dplyr::group_by(county_id, county, year) %>%
  dplyr::summarize(
    cog_1_mean      = mean(cog_1    , na.rm=T),
    cog_2_mean      = mean(cog_2    , na.rm=T),
    cog_3_mean      = mean(cog_3    , na.rm=T),
    phys_1_mean     = mean(phys_1   , na.rm=T),
    phys_2_mean     = mean(phys_2   , na.rm=T),
    phys_3_mean     = mean(phys_3   , na.rm=T)
  ) %>%
  dplyr::ungroup()


# ---- inspect -----------------------------------------------------------------
message(
  "Row Count          : ", scales::comma(nrow(ds)), "\n",
  "Unique subjects    : ", scales::comma(dplyr::n_distinct(ds$subject_id)), "\n",
  "Unique waves       : ", scales::comma(dplyr::n_distinct(ds$wave_id       )), "\n",
  "Unique counties    : ", scales::comma(dplyr::n_distinct(ds$county_id       )), "\n",
  "Unique years       : ", scales::comma(dplyr::n_distinct(ds$year    )), "\n",
  "Year range         : ", sprintf("%i ", range(ds$year)), "\n",
  # "Year range         : ", strftime(range(ds_program_month$month), "%Y-%m-%d  "), "\n",
  sep=""
)
ds %>%
  dplyr::count(county_id) %>%
  dplyr::mutate(n = scales::comma(n)) %>%
  tidyr::spread(county_id, n)

ds %>%
  # dplyr::filter(visit_all_completed_count > 0L) %>%
  # purrr::map(., ~mean(is.na(.)) ) %>%
  purrr::map(., ~mean(is.na(.) | as.character(.)=="Unknown")) %>%
  purrr::map(., ~round(., 3)) %>%
  tibble::as_tibble() %>%
  t()

# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds)
checkmate::assert_integer(  ds$subject_wave_id , any.missing=F , lower=1, upper=200   , unique=T)
checkmate::assert_integer(  ds$subject_id      , any.missing=F , lower=1001, upper=1200 )
checkmate::assert_integer(  ds$county_id       , any.missing=F , lower=51, upper=72     )
checkmate::assert_character(ds$county          , any.missing=F , pattern="^.{5,8}$"     )
checkmate::assert_integer(  ds$wave_id         , any.missing=F , lower=1, upper=10      )
checkmate::assert_integer(  ds$year            , any.missing=F , lower=2000, upper=2014 )
checkmate::assert_date(     ds$date_at_visit     , any.missing=F , lower=as.Date("2000-01-01"), upper=as.Date("2018-12-31") )
checkmate::assert_integer(  ds$age             , any.missing=F , lower=55, upper=84     )
checkmate::assert_character(ds$age_cut_4       , any.missing=F , pattern="^.{3,5}$"     )
checkmate::assert_logical(  ds$age_80_plus     , any.missing=F                          )
checkmate::assert_numeric(  ds$int_factor_1    , any.missing=F , lower=7, upper=20      )
checkmate::assert_numeric(  ds$slope_factor_1  , any.missing=F , lower=-1, upper=1      )
checkmate::assert_numeric(  ds$cog_1           , any.missing=F , lower=2, upper=8       )
checkmate::assert_numeric(  ds$cog_2           , any.missing=F , lower=3, upper=10      )
checkmate::assert_numeric(  ds$cog_3           , any.missing=F , lower=4, upper=12      )
checkmate::assert_numeric(  ds$phys_1          , any.missing=F , lower=1, upper=5       )
checkmate::assert_numeric(  ds$phys_2          , any.missing=F , lower=2, upper=7       )
checkmate::assert_numeric(  ds$phys_3          , any.missing=F , lower=0, upper=3       )

# ---- specify-columns-to-upload -----------------------------------------------
# Print colnames that `dplyr::select()`  should contain below:
#   cat(paste0("    ", colnames(ds), collapse=",\n"))

ds_slim <-
  ds %>%
  dplyr::select(
    subject_wave_id,
    subject_id,
    county_id,
    gender_id,
    race,
    ethnicity,
    county,
    wave_id,
    year,
    date_at_visit,
    age,
    age_cut_4,
    age_80_plus,
    int_factor_1,
    slope_factor_1,
    cog_1,
    cog_2,
    cog_3,
    phys_1,
    phys_2,
    phys_3
  ) %>%
  # dplyr::slice(1:100) %>%
  dplyr::mutate_if(is.logical, as.integer)       # Some databases & drivers need 0/1 instead of FALSE/TRUE.
ds_slim

# ---- save-to-disk ------------------------------------------------------------
readr::write_rds(ds_county        , config$path_county_derived          , compress="gz")
readr::write_rds(ds_county_year   , config$path_county_year_derived     , compress="gz")
readr::write_rds(ds_slim          , config$path_mlm_1_derived           , compress="gz")
