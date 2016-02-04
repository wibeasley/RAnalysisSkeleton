rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------


# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("dplyr")
requireNamespace("readr")
requireNamespace("testit")


# ---- declare-globals ---------------------------------------------------------


# ---- load-data ---------------------------------------------------------------


# ---- tweak-data --------------------------------------------------------------





# ---- verify-values -----------------------------------------------------------
testit::assert("All IDs should be nonmissing and positive.", all(!is.na(ds$CountyID) & (ds$CountyID>0)))

# ---- specify-columns-to-upload -----------------------------------------------


# ---- upload-to-db ------------------------------------------------------------
# ---- save-to-disk ------------------------------------------------------------
