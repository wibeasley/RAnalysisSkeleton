rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
import::from("magrittr", "%>%")

requireNamespace("readr")
requireNamespace("dplyr")
requireNamespace("DBI")
requireNamespace("odbc")

# ---- declare-globals ---------------------------------------------------------
# This is called by the files that transfer WIC and OHCA datsets to SQL Server
set.seed(6579) # Do this after the salt is created.  The seed is set so the fake csvs don't change on GitHub.
salt <- round(runif(1, min=1000000, max=9999999))

# ---- load-data ---------------------------------------------------------------
# Retrieve URIs of CSV, and retrieve County lookup table
channel <- DBI::dbConnect(odbc::odbc(), "zzzzChanelNamezzzz") #getSqlTypeInfo("Microsoft SQL Server") #odbcGetInfo(channel)
path_oklahoma     <- DBI::dbSendQuery(channel, "EXEC Security.prcUri @UriName = 'C1TEOklahoma'")[1, 'Value']
path_tulsa        <- DBI::dbSendQuery(channel, "EXEC Security.prcUri @UriName = 'C1TETulsa'"   )[1, 'Value']
path_rural        <- DBI::dbSendQuery(channel, "EXEC Security.prcUri @UriName = 'C1TERural'"   )[1, 'Value']
ds_county         <- DBI::dbReadTable(channel, "Osdh.tblLUCounty")
DBI::dbDisconnect(channel); rm(channel)

# Read the CSVs
ds_nurse_month_oklahoma   <- readr::read_csv(path_oklahoma)
ds_month_tulsa            <- readr::read_csv(path_tulsa)
ds_nurse_month_rural      <- readr::read_csv(path_rural)
rm(path_oklahoma, path_tulsa, path_rural)

ds_fake_name <- readr::read_csv("utility/te-generation/fake-names.csv", col_names = F) # From http://listofrandomnames.com/

# ---- tweak-data --------------------------------------------------------------
ds_fake_name <-
  ds_fake_name %>%
  dplyr::rename(Name = X1) %>%
  dplyr::group_by(Name) %>%          # Collapse any duplicated fake names; `dplyr::distinct()` would be more concise.
  dplyr::summarize()  %>%
  dplyr::ungroup()  %>% # Always leave the dataset ungrouped, so later operations act as expected.
  tibble::rowid_to_column("ID")

# ---- groom-oklahoma ----------------------------------------------------------
colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma)) # Sanitize illegal variable names.
# mean(is.na(ds_nurse_month_oklahoma$FMLA.Hours)); table(ds_nurse_month_oklahoma$FMLA.Hours)
# table(ds_nurse_month_oklahoma$FTE)
ds_nurse_month_oklahoma <-
  ds_nurse_month_oklahoma %>%
  dplyr::mutate(
    Employee..      = as.integer(as.factor(Employee..)),
    # Name          = OuhscMunge::hash_and_salt_sha_256(Name, salt_to_add=salt, required_mode="character", min_length_inclusive=1, max_length_inclusive=100),
    FTE             = sample(x=c(.5, .76, 1.0), size=dplyr::n(), replace=T, prob=c(.07, .03, .9)) ,
    # Year          = Year - 1,
    FMLA.Hours      = round(ifelse(runif(dplyr::n()) > .03, NA_real_, runif(dplyr::n(), min=0, max=160))),
    Training.Hours  = round(ifelse(runif(dplyr::n()) > .2,  NA_real_, runif(dplyr::n(), min=0, max=60)))
  ) %>%
  dplyr::select(-Name) %>%  #Drop the real name
  dplyr::left_join(ds_fake_name, by=c("Employee.."="ID"))

# ---- groom-tulsa -------------------------------------------------------------
# mean(is.na(ds_month_tulsa$FmlaSum)); table(ds_month_tulsa$FmlaSum)
ds_month_tulsa <-
  ds_month_tulsa %>%
  dplyr::mutate(
    FmlaSum     = round(ifelse(runif(dplyr::n()) > .35, NA_real_, runif(dplyr::n(), min=0, max=300)))
  )

# ---- groom-rural -------------------------------------------------------------
ds_nurse_month_rural <-
  ds_nurse_month_rural %>%
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
