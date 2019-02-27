# knitr::stitch_rmd(script="manipulation/mlm-scribe.R", output="stitched-output/manipulation/mlm-scribe.md")
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.


# ---- load-sources ------------------------------------------------------------
# source("manipulation/osdh/ellis/common-ellis.R")
# base::source(file="dal/osdh/arch/benchmark-client-program-arch.R") #Load retrieve_benchmark_client_program

# ---- load-packages -----------------------------------------------------------
library(magrittr, quietly=TRUE)
requireNamespace("DBI")
requireNamespace("odbc")
requireNamespace("dplyr")
requireNamespace("testit")
requireNamespace("lubridate")
requireNamespace("RcppRoll")
requireNamespace("OuhscMunge") # devtools::install_github(repo="OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
config                         <- config::get()
path_db                        <- config$path_database

sql_county <-
  "
    SELECT
      t.county_id
      ,luc.county_name      AS county
      ,avg(t.fte)           AS fte
  	  ,count(cog_1)         AS cog_1_count
  	  ,avg(cog_1)           AS cog_1
  	  ,avg(cog_2)           AS cog_2
  	  ,avg(cog_3)           AS cog_3
  	  ,avg(phys_1)          AS phys_1
  	  ,avg(phys_2)          AS phys_2
  	  ,avg(phys_3)          AS phys_3
    FROM te_month AS t
      LEFT JOIN county  AS luc ON   t.county_id  = luc.county_id
  	  LEFT JOIN subject AS   s ON luc.county_id  =   s.county_id
  	  LEFT JOIN mlm_1   AS   m ON   s.subject_id =   m.subject_id
    GROUP BY t.county_id, luc.county_name
    ORDER BY t.county_id
  "

sql_county_month <-
  "
    SELECT
      t.county_id
      ,luc.county_name      AS county
      ,t.month
      ,t.fte
      ,t.fte_approximated
      ,t.month_missing
      ,t.fte_rolling_median_11_month
    FROM te_month AS t
      LEFT JOIN county AS luc ON t.county_id = luc.county_id
    ORDER BY t.county_id, t.month
  "

# ---- load-data ---------------------------------------------------------------
# ds_lu_program   <- retrieve_program()
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
# DBI::dbListTables(cnn)
ds_county           <- DBI::dbGetQuery(cnn, sql_county)
ds_county_month     <- DBI::dbGetQuery(cnn, sql_county_month)
DBI::dbDisconnect(cnn); rm(cnn, sql_county_month, sql_county)

checkmate::assert_data_frame(ds_county           , nrows = 77)
checkmate::assert_data_frame(ds_county_month     , min.rows = 2 *77)

# ---- tweak-data --------------------------------------------------------------
dim(ds_county)
ds_county <-
  ds_county %>%
  tibble::as_tibble()

dim(ds_county_month)
ds_county_month <-
  ds_county_month %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    month                 = as.Date(month),
    fte_approximated      = as.logical(fte_approximated),
    month_missing         = as.logical(month_missing)
  )
dim(ds_county_month)

# ---- inspect -----------------------------------------------------------------
cat(
  "Unique counties    : ", scales::comma(dplyr::n_distinct(ds_county_month$county_id)), "\n",
  "Unique months      : ", scales::comma(dplyr::n_distinct(ds_county_month$month    )), "\n",
  "Month range        : ", strftime(range(ds_county_month$month), "%Y-%m-%d  "), "\n",
  sep=""
)
ds_county_month %>%
  dplyr::count(county_id) %>%
  dplyr::mutate(n = scales::comma(n)) %>%
  tidyr::spread(county_id, n)

ds_county_month %>%
  # dplyr::filter(visit_all_completed_count > 0L) %>%
  # purrr::map(., ~mean(is.na(.)) ) %>%
  purrr::map(., ~mean(is.na(.) | as.character(.)=="Unknown")) %>%
  purrr::map(., ~round(., 3)) %>%
  tibble::as_tibble() %>%
  t()

# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds_county)
checkmate::assert_integer(  ds_county$county_id , any.missing=F , lower=1, upper=77   , unique=T)
checkmate::assert_character(ds_county$county    , any.missing=F , pattern="^.{3,12}$" , unique=T)
checkmate::assert_numeric(  ds_county$fte       , any.missing=F , lower=0, upper=22   )
checkmate::assert_numeric(  ds_county$cog_1       , any.missing=T , lower=4, upper=6    )
checkmate::assert_numeric(  ds_county$cog_2       , any.missing=T , lower=5, upper=7    )
checkmate::assert_numeric(  ds_county$cog_3       , any.missing=T , lower=6, upper=9    )
checkmate::assert_numeric(  ds_county$phys_1      , any.missing=T , lower=2, upper=4    )
checkmate::assert_numeric(  ds_county$phys_2      , any.missing=T , lower=3, upper=5    )
checkmate::assert_numeric(  ds_county$phys_3      , any.missing=T , lower=1, upper=2    )


checkmate::assert_integer(  ds_county_month$county_id                   , any.missing=F , lower=1, upper=77                                        )
checkmate::assert_character(ds_county_month$county                      , any.missing=F , pattern="^.{3,12}$"                                      )
checkmate::assert_date(     ds_county_month$month                       , any.missing=F , lower=as.Date("2012-06-15"), upper=as.Date("2015-09-15") )
checkmate::assert_numeric(  ds_county_month$fte                         , any.missing=F , lower=0, upper=27                                        )
checkmate::assert_logical(  ds_county_month$fte_approximated            , any.missing=F                                                            )
checkmate::assert_logical(  ds_county_month$month_missing               , any.missing=F                                                            )
checkmate::assert_numeric(  ds_county_month$fte_rolling_median_11_month , any.missing=T , lower=0, upper=24                                        )

county_month_combo   <- paste(ds_county_month$county_id, ds_county_month$month)
checkmate::assert_character(county_month_combo, pattern  ="^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$"            , any.missing=F, unique=T)

# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds_county_month)) # Print colnames for line below.
columns_to_write_county_month <- c(
  "county_id", "county", "month", "fte", "fte_approximated",
  "month_missing", "fte_rolling_median_11_month"
)
ds_slim_county_month <-
  ds_county_month %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(!!columns_to_write_county_month)
ds_slim_county_month

rm(columns_to_write_county_month)

# dput(colnames(ds_county)) # Print colnames for line below.
columns_to_write_county <- c(
  "county_id", "county", "fte",
  "cog_1_count",
  "cog_1", "cog_2", "cog_3",
  "phys_1", "phys_2", "phys_3"
)
ds_slim_county <-
  ds_county %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(!!columns_to_write_county)
ds_slim_county

rm(columns_to_write_county)

# ---- save-to-disk ------------------------------------------------------------
readr::write_rds(ds_slim_county        , config$path_te_county           , compress="gz")
readr::write_rds(ds_slim_county_month  , config$path_te_county_month     , compress="gz")
