# knitr::stitch_rmd(script="utility/reproduce.R", output="stitched-output/utility/reproduce.md")
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("purrr")
# requireNamespace("checkmate")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# config        <- config::get()

# Allow multiple files below to have the same chunk name.
#    If the `root.dir` option is properly managed in the Rmd files, no files will be overwritten.
options(knitr.duplicate.label = "allow")

ds_rail  <- tibble::tribble(
  ~fx               , ~path,

  # Simulate observed data
  "run_file_r"      , "manipulation/simulation/simulate-mlm-1.R",
  # "run_file_r"      , "manipulation/simulation/simulate-te.R",

  # First run the manipulation files to prepare the dataset(s).
  "run_file_r"      , "manipulation/car-ellis.R",
  "run_file_r"      , "manipulation/mlm-1-ellis.R",
  "run_file_r"      , "manipulation/te-ellis.R",
  "run_file_r"      , "manipulation/subject-1-ellis.R",

  # "run_ferry_sql" , "manipulation/inserts-to-normalized-tables.sql"
  "run_file_r"      , "manipulation/randomization-block-simple.R",

  # Scribes
  "run_file_r"    , "manipulation/mlm-1-scribe.R",
  "run_file_r"    , "manipulation/te-scribe.R",

  # Reports
  "run_rmd"       , "analysis/car-report-1/car-report-1.Rmd",
  "run_rmd"       , "analysis/report-te-1/report-te-1.Rmd",

  # Dashboards
  "run_rmd"       , "analysis/dashboard-1/dashboard-1.Rmd"
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
run_rmd <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  path_out <- rmarkdown::render(minion, envir=new.env())
  Sys.sleep(3) # Sleep for three secs, to let pandoc finish
  message(path_out)
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
