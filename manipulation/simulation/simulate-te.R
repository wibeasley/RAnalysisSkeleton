rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
library(magrittr, quietly=TRUE)
requireNamespace("readr")
requireNamespace("dplyr")
requireNamespace("RODBC")

# ---- declare-globals ---------------------------------------------------------
# This is called by the files that transfer WIC and OHCA datsets to SQL Server
hash_and_salt_sha_256 <- function( x, min_length_inclusive, max_length_inclusive, required_mode, salt_to_add ) {
  stopifnot(mode(x)==required_mode)
  x <- ifelse(x==0, NA_integer_, x)
  stopifnot(all(is.na(x) | (min_length_inclusive <= stringr::str_length(x) & stringr::str_length(x)<=max_length_inclusive) ))
  salted <- paste0(x, salt_to_add)
  hash <- digest::digest(object=salted, algo="sha256")
  return( ifelse(is.na(x), NA_character_, hash) )
}
salt <- round(runif(1, min=1000000, max=9999999))

set.seed(6579) # Do this after the salt is created.  The seed is set so the fake csvs don't change on GitHub.

# ---- load-data ---------------------------------------------------------------
# Retrieve URIs of CSV, and retrieve County lookup table
channel <- RODBC::odbcConnect("zzzzChanelNamezzzz") #getSqlTypeInfo("Microsoft SQL Server") #odbcGetInfo(channel)
path_oklahoma     <- RODBC::sqlQuery(channel, "EXEC Security.prcUri @UriName = 'C1TEOklahoma'", stringsAsFactors=FALSE)[1, 'Value']
path_tulsa        <- RODBC::sqlQuery(channel, "EXEC Security.prcUri @UriName = 'C1TETulsa'", stringsAsFactors=FALSE)[1, 'Value']
path_rural        <- RODBC::sqlQuery(channel, "EXEC Security.prcUri @UriName = 'C1TERural'", stringsAsFactors=FALSE)[1, 'Value']
ds_county         <- RODBC::sqlFetch(channel, sqtable="Osdh.tblLUCounty", stringsAsFactors=FALSE)
RODBC::odbcClose(channel); rm(channel)

# Read the CSVs
ds_nurse_month_oklahoma   <- readr::read_csv(path_oklahoma)
ds_month_tulsa            <- readr::read_csv(path_tulsa)
ds_nurse_month_rural      <- readr::read_csv(path_rural)
rm(path_oklahoma, path_tulsa, path_rural)

ds_fake_name <- readr::read_csv("./utility/te-generation/fake-names.csv", col_names = F) # From http://listofrandomnames.com/

# ---- tweak-data --------------------------------------------------------------
ds_fake_name <- ds_fake_name %>%
  dplyr::rename(Name = X1) %>%
  dplyr::group_by(Name) %>%          # Collapse any duplicated fake names
  dplyr::summarize()  %>%
  dplyr::ungroup()  %>% # Always leave the dataset ungrouped, so later operations act as expected.
  dplyr::mutate(ID = seq_len(dplyr::n()))

# ---- groom-oklahoma ----------------------------------------------------------
colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma)) #Sanitize illegal variable names.
# mean(is.na(ds_nurse_month_oklahoma$FMLA.Hours)); table(ds_nurse_month_oklahoma$FMLA.Hours)
# table(ds_nurse_month_oklahoma$FTE)
ds_nurse_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::mutate(
    Employee..      = as.integer(as.factor(Employee..)),
    #Name           = hash_and_salt_sha_256(Name, salt_to_add=salt, required_mode="character", min_length_inclusive=1, max_length_inclusive=100),
    FTE             = sample(x=c(.5, .76, 1.0), size=dplyr::n(), replace=T, prob=c(.07, .03, .9)) ,
    # Year            = Year - 1,
    FMLA.Hours      = round(ifelse(runif(dplyr::n()) > .03, NA_real_, runif(dplyr::n(), min=0, max=160))),
    Training.Hours  = round(ifelse(runif(dplyr::n()) > .2,  NA_real_, runif(dplyr::n(), min=0, max=60)))
  ) %>%
  dplyr::select(-Name) %>%  #Drop the real name
  dplyr::left_join(ds_fake_name, by=c("Employee.."="ID"))

# ---- groom-tulsa -------------------------------------------------------------
# mean(is.na(ds_month_tulsa$FmlaSum)); table(ds_month_tulsa$FmlaSum)
ds_month_tulsa <- ds_month_tulsa %>%
  dplyr::mutate(
    FmlaSum     = round(ifelse(runif(dplyr::n()) > .35, NA_real_, runif(dplyr::n(), min=0, max=300)))
  )

# ---- groom-rural -------------------------------------------------------------
ds_nurse_month_rural <- ds_nurse_month_rural %>%
  dplyr::mutate(
    EMPLOYEEID  = as.integer(as.factor(NAME)) + max(ds_nurse_month_oklahoma$Employee..),
    REGIONID    = as.integer(as.factor(LEAD_NURSE)),
    FTE         = paste0(sample(x=c(50, 76, 100), size=dplyr::n(), replace=T, prob=c(.07, .03, .9)), " %")
  ) %>%
  dplyr::select(
    -LASTNAME
    , -FIRSTNAME
    #, -HOME_COUNTY
     , -MISC
    , -TYPE
    , -LEAD_NURSE
    #, -FTE
    , -C1_START_YR
    , -EFFECTIVE_DATE
    , -HR
    , -OTHER
    , -TERMINATED
    , -NEW_HIRE
    , -MIECHV
    # , -PERIOD
    , -MIECHV_STARTDATE
    , -MIECHV_ENDDATE
    , -TERMINATED_DATE
  ) %>%
  dplyr::select(-NAME) %>%  # Drop the real name
  dplyr::left_join(ds_fake_name, by=c("EMPLOYEEID"="ID"))

# ---- save-to-disk ------------------------------------------------------------
readr::write_csv(ds_nurse_month_oklahoma, "data-public/raw/te/nurse-month-oklahoma.csv") # Replace column names with: Employee #,Year,Month,FTE,FMLA Hours,Training Hours,Name
readr::write_csv(ds_month_tulsa,          "data-public/raw/te/month-tulsa.csv")
readr::write_csv(ds_nurse_month_rural,    "data-public/raw/te/nurse-month-rural.csv")
readr::write_csv(ds_county,               "data-public/raw/te/county.csv")
