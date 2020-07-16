rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
import::from("magrittr", "%>%")

requireNamespace("readr")
requireNamespace("tibble")
requireNamespace("tidyr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
set.seed(94)                          # Set seed in care parts need to be modified later.
block_count                   <- 50L  # Some arbitrarily large number
block_size                    <- 1L   # Number of assignment cycles per block.
assignment_possible           <- c("tx", "control")
assignment_possible_block     <- rep(assignment_possible, each=block_size)

path_out                      <- "data-public/derived/randomized-block-simple.csv"


# ---- load-data ---------------------------------------------------------------

# ---- tweak-data --------------------------------------------------------------

# ---- assign ------------------------------------------------------------------
ds <-
  tibble::tibble(
    assignment_id         = seq_len(block_count * block_size * length(assignment_possible)),
    block_id              = rep(seq_len(block_count), each=length(assignment_possible))
  )

ds <-
  ds %>%
  dplyr::group_by(block_id) %>%
  dplyr::mutate(
    condition           = sample(assignment_possible_block, replace=FALSE),
    client_id           = '-to be assigned-',
    year_assigned       = 2016L,
    month_assigned      = 9L,
    day_assigned        = '-enter today-'
  ) %>%
  dplyr::ungroup()


# ---- verify-values -----------------------------------------------------------
# Sniff out problems
testit::assert("The `assignment_id` must be nonmissing & positive.", all(!is.na(ds$assignment_id) & (ds$assignment_id>=1)))
testit::assert("The `block_id` must be nonmissing & positive.", all(!is.na(ds$block_id) & (ds$block_id>=1)))
testit::assert("The `condition` value must be nonmissing.", all(!is.na(ds$condition)))

testit::assert("The block_id-condition combination should be unique.", all(!duplicated(paste(ds$block_id, ds$condition))))


# ---- specify-columns-to-upload -----------------------------------------------
# Print colnames that `dplyr::select()`  should contain below:
#  cat(paste0("    ", colnames(ds), collapse=",\n"))

ds_slim <-
  ds %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(
    assignment_id,
    block_id,
    condition,
    client_id,
    year_assigned,
    month_assigned,
    day_assigned
  )

ds_slim


# # ---- upload-to-db ------------------------------------------------------------
# (startTime <- Sys.time())
# dbTable <- "Osdh.tblC1TEMonth"
# channel <- RODBC::odbcConnect("te-example") #getSqlTypeInfo("Microsoft SQL Server") #;odbcGetInfo(channel)
#
# columnInfo <- RODBC::sqlColumns(channel, dbTable)
# varTypes <- as.character(columnInfo$TYPE_NAME)
# names(varTypes) <- as.character(columnInfo$COLUMN_NAME)  #varTypes
#
# RODBC::sqlClear(channel, dbTable)
# RODBC::sqlSave(channel, ds_slim, dbTable, append=TRUE, rownames=FALSE, fast=TRUE, varTypes=varTypes)
# RODBC::odbcClose(channel)
# rm(columnInfo, channel, columns_to_write, dbTable, varTypes)
# (elapsedDuration <-  Sys.time() - startTime) #21.4032 secs 2015-10-31


# ---- save-to-disk ------------------------------------------------------------
readr::write_csv(ds, path_out)

# Consider writing to sqlite (with RSQLite) if there's no PHI, or a central database if there is PHI.
