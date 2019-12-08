rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
# ---- load-sources ------------------------------------------------------------


# ---- load-packages -----------------------------------------------------------
import::from("magrittr", "%>%")
requireNamespace("readr")
requireNamespace("dplyr")
requireNamespace("checkmate")


# ---- declare-globals ---------------------------------------------------------


# ---- load-data ---------------------------------------------------------------


# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds_county) # Help write `dplyr::select()` call.


# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds) # Run this to line to start the checkmate asserts.
checkmate::assert_integer(  ds$id                       , any.missing=F , lower=   1, upper=  32  , unique=T)

# ---- specify-columns-to-upload -----------------------------------------------
# Print colnames that `dplyr::select()`  should contain below:
#   cat(paste0("    ", colnames(ds), collapse=",\n"))


# ---- save-to-db --------------------------------------------------------------


# ---- save-to-disk ------------------------------------------------------------
