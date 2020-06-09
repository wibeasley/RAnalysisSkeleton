# knitr::stitch_rmd(script="flow.R", output="stitched-output/flow.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
import::from("magrittr", "%>%")

requireNamespace("purrr")
requireNamespace("rlang")
# requireNamespace("checkmate")
# requireNamespace("fs")
requireNamespace("OuhscMunge") # remotes::install_github("OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# Allow multiple files below to have the same chunk name.
#    If the `root.dir` option is properly managed in the Rmd files, no files will be overwritten.
options(knitr.duplicate.label = "allow")

config        <- config::get()

# open log
if( interactive() ) {
  sink_log <- FALSE
} else {
  message("Creating flow log file at ", config$path_log_flow)

  if( !dir.exists(dirname(config$path_log_flow)) ) {
    # Create a month-specific directory, so they're easier to find & compress later.
    dir.create(dirname(config$path_log_flow), recursive=T)
  }

  file_log  <- file(
    description   = config$path_log_flow,
    open          = "wt"
  )
  sink(
    file    = file_log,
    type    = "message"
  )
  sink_log <- TRUE
}
ds_rail  <- tibble::tribble(
  ~fx               , ~path,

  # Simulate observed data
  "run_r"     , "manipulation/simulation/simulate-mlm-1.R",
  # "run_r"   , "manipulation/simulation/simulate-te.R",

  # ETL (extract-transform-load) the data from the outside world.
  "run_r"     , "manipulation/ss-county-ellis.R",
  "run_r"     , "manipulation/car-ellis.R",
  "run_r"     , "manipulation/mlm-1-ellis.R",
  "run_r"     , "manipulation/te-ellis.R",
  "run_r"     , "manipulation/subject-1-ellis.R",

  # Second-level manipulation on data inside the warehouse.
  # "run_sql" , "manipulation/inserts-to-normalized-tables.sql"
  "run_r"     , "manipulation/randomization-block-simple.R",

  # Scribes create analysis-ready rectangles.
  "run_r"     , "manipulation/mlm-1-scribe.R",
  "run_r"     , "manipulation/te-scribe.R",

  # Reports for human consumers.
  "run_rmd"   , "analysis/car-report-1/car-report-1.Rmd",
  "run_rmd"   , "analysis/report-te-1/report-te-1.Rmd"

  # Dashboards for human consumers.
  # "run_rmd" , "analysis/dashboard-1/dashboard-1.Rmd"
)

run_r <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  base::source(minion, local=new.env())
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_sql <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  OuhscMunge::execute_sql_file(minion, config$dsn_staging)
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_rmd <- function( minion ) {
  message("Pandoc available: ", rmarkdown::pandoc_available())
  message("Pandoc version: ", rmarkdown::pandoc_version())
  
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  path_out <- rmarkdown::render(minion, envir=new.env())
  Sys.sleep(3) # Sleep for three secs, to let pandoc finish
  message(path_out)
  
  # Uncomment to copy the undated version to a different location. 
  # If saving to a remote drive, this works better than trying to save directly from `rmarkdown::render()`.
  # To use this, you'll need a version of `run_rmd()` that's specialized for the specific rmd.
  # fs::file_copy(path_out, config$path_out_remote, overwrite = TRUE) 

  # Uncomment to save a dated version to a different location.
  # path_out_archive <- strftime(Sys.Date(), config$path_report_screen_archive)
  # if( !dir.exists(dirname(path_out_archive)) ) {
  #   # Create a month-specific directory, so they're easier to find & compress later.
  #   message("Creating subdirectory for archived eligibility reports: `", dirname(path_out_archive), "`.")
  #   dir.create(dirname(path_out_archive), recursive=T)
  # }
  # archive_successful <- file.copy(path_out, path_out_archive, overwrite=TRUE)
  # message("Archive success: ", archive_successful, " at `", path_out_archive, "`.")
  
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
message("Starting flow of `", basename(base::getwd()), "` at ", Sys.time(), ".")

warn_level_initial <- as.integer(options("warn"))
# options(warn=0)  # warnings are stored until the top–level function returns
# options(warn=2)  # treat warnings as errors

elapsed_duration <- system.time({
  purrr::map2_lgl(
    ds_rail$fx,
    ds_rail$path,
    function(fn, args) rlang::exec(fn, !!!args)
  )
})

message("Completed flow of `", basename(base::getwd()), "` at ", Sys.time(), "")
elapsed_duration
options(warn=warn_level_initial)  # Restore the whatever warning level you started with.

# ---- close-log ---------------------------------------------------------------
# close(file_log)
if( sink_log ) {
  sink(file = NULL, type = "message") # ends the last diversion (of the specified type).
  message("Closing flow log file at ", gsub("/", "\\\\", config$path_log_flow))
}

# bash: Rscript flow.R
