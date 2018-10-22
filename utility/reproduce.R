# knitr::stitch_rmd(script="./utility/reproduce.R", output="./stitched-output/utility/reproduce.md")
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("purrr")
# requireNamespace("checkmate")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# config        <- config::get(file="data-public/metadata/config.yml")

ds_rail  <- tibble::tribble(
  ~fx               , ~path,
  "run_file_r"      , "./manipulation/te-ellis.R",
  "run_file_r"      , "./manipulation/car-ellis.R",
  "run_file_r"      , "./manipulation/randomization-block-simple.R"

  # "run_ferry_sql"   , "./manipulation/inserts-to-normalized-tables.sql"
)

run_file_r <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  base::source(minion, local=new.env())
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_ferry_sql <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  OuhscMunge::execute_sql_file(minion, config$dsn_staging)
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}

(file_found <- purrr::map_lgl(ds_rail$path, file.exists))
if( !all(file_found) ) {
  warning("--Missing files-- \n", paste0(ds_rail$path[!file_found], collapse="\n"))
  stop("All source files to be run should exist.")
}

# ---- load-data ---------------------------------------------------------------

# ---- tweak-data --------------------------------------------------------------

# ---- run ---------------------------------------------------------------------
message("Starting update of files at ", Sys.time(), ".")
elapsed_time <- system.time({
  purrr::invoke_map_lgl(
    ds_rail$fx,
    ds_rail$path
  )
})

message("Completed update of files at ", Sys.time(), "")
elapsed_time
