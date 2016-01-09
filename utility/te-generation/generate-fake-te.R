rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# load_sources ------------------------------------------------------------

# load_packages -----------------------------------------------------------
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)
requireNamespace("readr")
requireNamespace("dplyr")

# declare_globals ---------------------------------------------------------
#This is called by the files that transfer WIC and OHCA datsets to SQL Server
HashAndSaltSha256 <- function( x, minLengthInclusive, maxLengthInclusive, requiredMode, saltToAdd ) {
  stopifnot(mode(x)==requiredMode)
  x <- ifelse(x==0, NA_integer_, x)
  stopifnot(all(is.na(x) | (minLengthInclusive <= stringr::str_length(x) & stringr::str_length(x)<=maxLengthInclusive) ))
  salted <- paste0(x, saltToAdd)
  hash <- digest::digest(object=salted, algo="sha256")
  return( ifelse(is.na(x), NA_character_, hash) )
}
salt <- round(runif(1, min=1000000, max=9999999))

set.seed(6579) #Do this after the salt is created.  The seed is set so the fake csvs don't change on GitHub.
# load_data ---------------------------------------------------------------

# Retrieve URIs of CSV, and retrieve County lookup table
channel <- RODBC::odbcConnect("zzzzChanelNamezzzz") #getSqlTypeInfo("Microsoft SQL Server") #odbcGetInfo(channel)
pathOklahoma    <- RODBC::sqlQuery(channel, "EXEC Security.prcUri @UriName = 'C1TEOklahoma'", stringsAsFactors=FALSE)[1, 'Value']
pathTulsa       <- RODBC::sqlQuery(channel, "EXEC Security.prcUri @UriName = 'C1TETulsa'", stringsAsFactors=FALSE)[1, 'Value']
pathRural       <- RODBC::sqlQuery(channel, "EXEC Security.prcUri @UriName = 'C1TERural'", stringsAsFactors=FALSE)[1, 'Value']
dsCounty        <- RODBC::sqlFetch(channel, sqtable="Osdh.tblLUCounty", stringsAsFactors=FALSE)
RODBC::odbcClose(channel); rm(channel)

# Read the CSVs
dsNurseMonthOklahoma <- readr::read_csv(pathOklahoma)
dsMonthTulsa         <- readr::read_csv(pathTulsa)
dsNurseMonthRural    <- readr::read_csv(pathRural)
rm(pathOklahoma, pathTulsa, pathRural)

dsFakeName <- readr::read_csv("./utility/te-generation/fake-names.csv", col_names = F) #From http://listofrandomnames.com/

# tweak_data --------------------------------------------------------------
dsFakeName <- dsFakeName %>%
  dplyr::rename(Name = X1) %>%
  dplyr::group_by(Name) %>%          #Collapse any duplicated fake names
  dplyr::summarize() %>%
  dplyr::mutate(ID = seq_len(n()))

# groom_oklahoma ----------------------------------------------------------
colnames(dsNurseMonthOklahoma) <- make.names(colnames(dsNurseMonthOklahoma)) #Sanitize illegal variable names.
# mean(is.na(dsNurseMonthOklahoma$FMLA.Hours)); table(dsNurseMonthOklahoma$FMLA.Hours)
# table(dsNurseMonthOklahoma$FTE)
dsNurseMonthOklahoma <- dsNurseMonthOklahoma %>%
  dplyr::mutate(
    Employee..      = as.integer(as.factor(Employee..)),
    #Name           = HashAndSaltSha256(Name, saltToAdd=salt, requiredMode="character", minLengthInclusive=1, maxLengthInclusive=100),
    FTE             = sample(x=c(.5, .76, 1.0), size=n(), replace=T, prob=c(.07, .03, .9)) ,
    # Year            = Year - 1,
    FMLA.Hours      = round(ifelse(runif(n()) > .03, NA_real_, runif(n(), min=0, max=160))),
    Training.Hours  = round(ifelse(runif(n()) > .2,  NA_real_, runif(n(), min=0, max=60)))
  ) %>%
  dplyr::select(-Name) %>%  #Drop the real name
  dplyr::left_join(dsFakeName, by=c("Employee.."="ID"))

# groom_tulsa -------------------------------------------------------------
# mean(is.na(dsMonthTulsa$FmlaSum)); table(dsMonthTulsa$FmlaSum)
dsMonthTulsa <- dsMonthTulsa %>%
  dplyr::mutate(
    FmlaSum      = round(ifelse(runif(n()) > .35, NA_real_, runif(n(), min=0, max=300)))
  )

# groom_rural -------------------------------------------------------------
dsNurseMonthRural <- dsNurseMonthRural %>%
  dplyr::mutate(
    EMPLOYEEID  = as.integer(as.factor(NAME)) + max(dsNurseMonthOklahoma$Employee..),
    REGIONID    = as.integer(as.factor(LEAD_NURSE)),
    FTE         = paste0(sample(x=c(50, 76, 100), size=n(), replace=T, prob=c(.07, .03, .9)), " %")
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
  dplyr::select(-NAME) %>%  #Drop the real name
  dplyr::left_join(dsFakeName, by=c("EMPLOYEEID"="ID"))

# save_to_disk ------------------------------------------------------------
readr::write_csv(dsNurseMonthOklahoma, "./PhiFreeDatasetsCache/nurse-month-oklahoma.csv") #Replace column names with: Employee #,Year,Month,FTE,FMLA Hours,Training Hours,Name
readr::write_csv(dsMonthTulsa,         "./PhiFreeDatasetsCache/month-tulsa.csv")
readr::write_csv(dsNurseMonthRural,    "./PhiFreeDatasetsCache/nurse-month-rural.csv")
readr::write_csv(dsCounty,             "./PhiFreeDatasetsCache/county.csv")
