rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------


# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("readr")
requireNamespace("dplyr")
requireNamespace("testit")
requireNamespace("checkmate")


# ---- declare-globals ---------------------------------------------------------


# ---- load-data ---------------------------------------------------------------


# ---- tweak-data --------------------------------------------------------------
# OuhscMunge::column_rename_headstart(ds) # Spit out columns to help populate arguments to `dplyr::rename()` or `dplyr::select()`.


# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds) # Run this to line to start the checkmate asserts.
checkmate::assert_integer(  ds$id                       , any.missing=F , lower=   1, upper=  32  , unique=T)

testit::assert("All IDs should be nonmissing and positive.", all(!is.na(id) & (ds$id>0)))

# ---- specify-columns-to-upload -----------------------------------------------
# dput(colnames(ds))

# ---- save-to-db --------------------------------------------------------------


# ---- save-to-disk ------------------------------------------------------------
