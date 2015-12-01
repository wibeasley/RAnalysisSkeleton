



This report was automatically generated with the R package **knitr**
(version 1.11.3).


```r
# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./manipulation/stitched-output/te-ellis.md")

rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# load_sources ------------------------------------------------------------

# load_packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(RODBC, quietly=TRUE)
library(magrittr, quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("car", quietly=TRUE) #For it's `recode()` function.

# declare_globals ---------------------------------------------------------
# Constant values that won't change.
pathOutUnified             <- "data-phi-free/derived/county-month-te.csv"
countiesToDropFromRural    <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
defaultDayOfMonth          <- 15L      # Summarize each month at its (rough) midpoint.
possibleCountyIDs          <- 1L:77L   #There are 77 counties.
thresholdMeanFteToFillIn   <- 10L      #Any county averaging over 10 hours can be filled in with its mean.

# URIs of CSV and County lookup table
pathInOklahoma  <- "./data-phi-free/raw/te/nurse-month-oklahoma.csv"
pathInTulsa     <- "./data-phi-free/raw/te/month-tulsa.csv"
pathInRural     <- "./data-phi-free/raw/te/nurse-month-rural.csv"
pathCounty      <- "./data-phi-free/raw/te/county.csv"

# load_data ---------------------------------------------------------------
# Read the CSVs
dsNurseMonthOklahoma <- readr::read_csv(pathInOklahoma)
dsMonthTulsa         <- readr::read_csv(pathInTulsa)
dsNurseMonthRural    <- readr::read_csv(pathInRural)
dsCounty             <- readr::read_csv(pathCounty)

rm(pathInOklahoma, pathInTulsa, pathInRural, pathCounty)
dsNurseMonthOklahoma
```

```
## Source: local data frame [1,480 x 7]
## 
##    Employee #  Year Month   FTE FMLA Hours Training Hours          Name
##         (int) (int) (int) (dbl)      (int)          (int)         (chr)
## 1           1  2009     1     1         NA             50 Akilah Amyx  
## 2           1  2009     2     1         NA             47 Akilah Amyx  
## 3           1  2009     3     1         NA             36 Akilah Amyx  
## 4           1  2009     4     1         NA             NA Akilah Amyx  
## 5           1  2009     5     1         NA             NA Akilah Amyx  
## 6           1  2009     6     1         NA             NA Akilah Amyx  
## 7           1  2009     7     1         NA             NA Akilah Amyx  
## 8           1  2009     8     1         NA             NA Akilah Amyx  
## 9           1  2009     9     1         NA             NA Akilah Amyx  
## 10          1  2009    10     1         NA             NA Akilah Amyx  
## ..        ...   ...   ...   ...        ...            ...           ...
```

```r
dsMonthTulsa
```

```
## Source: local data frame [80 x 3]
## 
##         Month FteSum FmlaSum
##         (chr)  (dbl)   (int)
## 1   1/15/2009   25.5      NA
## 2   2/15/2009   26.5      NA
## 3   3/15/2009   26.5      NA
## 4   4/15/2009   26.5      NA
## 5   5/15/2009   25.5      NA
## 6   6/15/2009   25.5      NA
## 7   7/15/2009   25.5      NA
## 8   8/15/2009   24.5      63
## 9   9/15/2009   23.5      NA
## 10 10/15/2009   23.5      NA
## ..        ...    ...     ...
```

```r
dsNurseMonthRural
```

```
## Source: local data frame [4,726 x 6]
## 
##     HOME_COUNTY   FTE  PERIOD EMPLOYEEID REGIONID            Name
##           (chr) (int)   (chr)      (int)    (int)           (chr)
## 1  Pottawatomie   100 06/2012         46       49 Cheree Crites  
## 2  Pottawatomie    50 08/2012         46       49 Cheree Crites  
## 3  Pottawatomie   100 09/2012         46       49 Cheree Crites  
## 4  Pottawatomie   100 10/2012         46       49 Cheree Crites  
## 5  Pottawatomie   100 12/2012         46       49 Cheree Crites  
## 6  Pottawatomie    50 01/2013         46       49 Cheree Crites  
## 7  Pottawatomie   100 02/2013         46       49 Cheree Crites  
## 8      Oklahoma   100 08/2012         47       44 Cheryll Canez  
## 9      Oklahoma   100 09/2012         47       44 Cheryll Canez  
## 10     Oklahoma   100 10/2012         47       44 Cheryll Canez  
## ..          ...   ...     ...        ...      ...             ...
```

```r
dsCounty
```

```
## Source: local data frame [77 x 13]
## 
##    CountyID CountyName GeoID FipsCode FundingC1 FundingOcap
##       (int)      (chr) (int)    (int)     (int)       (int)
## 1         1      Adair 40001        1         1           0
## 2         2    Alfalfa 40003        3         0           0
## 3         3      Atoka 40005        5         1           0
## 4         4     Beaver 40007        7         0           0
## 5         5    Beckham 40009        9         1           0
## 6         6     Blaine 40011       11         1           0
## 7         7      Bryan 40013       13         1           0
## 8         8      Caddo 40015       15         1           0
## 9         9   Canadian 40017       17         1           0
## 10       10     Carter 40019       19         1           0
## ..      ...        ...   ...      ...       ...         ...
## Variables not shown: C1LeadNurseRegion (int), C1LeadNurseName (chr), Urban
##   (int), LabelLongitude (dbl), LabelLatitude (dbl), MiechvEvaluation
##   (int), MiechvFormula (int).
```

```r
# tweak_data --------------------------------------------------------------
# dsNurseMonthRuralOklahoma <- dsNurseMonthRural[dsNurseMonthRural$HOME_COUNTY=="Oklahoma", ]

# groom_oklahoma ----------------------------------------------------------

# Sanitize illegal variable names.
colnames(dsNurseMonthOklahoma) <- make.names(colnames(dsNurseMonthOklahoma))

# Groom the nurse-month dataset for Oklahoma County.
dsNurseMonthOklahoma <- dsNurseMonthOklahoma %>%
  dplyr::rename_(
    "EmployeeNumber"    = "Employee.."         # Used to be "Employee #" before sanitizing.
    , "EmployeeName"    = "Name"
    , "Year"            = "Year"
    , "Month"           = "Month"
    , "Fte"             = "FTE"
    , "FmlaHours"       = "FMLA.Hours"         # Used to be "FMLA Hours" before sanitizing.
    , "TrainingHours"   = "Training.Hours"     # Used to be "Training Hours" before sanitizing.
  ) %>%
  dplyr::mutate(
    CountyID        = dsCounty[dsCounty$CountyName=="Oklahoma", ]$CountyID,  # Dynamically determine county ID.
    Month           = as.Date(ISOdate(Year, Month, defaultDayOfMonth)),      # Combine fields for one date.
    # FmlaHours     = ifelse(!is.na(FmlaHours), FmlaHours, 0.0),             # Set missing values to zero.
    TrainingHours   = ifelse(!is.na(TrainingHours), TrainingHours, 0.0)      # Set missing values to zero.
  ) %>%
  dplyr::select(      # Drop unecessary variables (ie, defensive programming)
    -EmployeeNumber,
    -EmployeeName,
    -Year
  )
dsNurseMonthOklahoma
```

```
## Source: local data frame [1,480 x 5]
## 
##         Month   Fte FmlaHours TrainingHours CountyID
##        (date) (dbl)     (int)         (dbl)    (int)
## 1  2009-01-15     1        NA            50       55
## 2  2009-02-15     1        NA            47       55
## 3  2009-03-15     1        NA            36       55
## 4  2009-04-15     1        NA             0       55
## 5  2009-05-15     1        NA             0       55
## 6  2009-06-15     1        NA             0       55
## 7  2009-07-15     1        NA             0       55
## 8  2009-08-15     1        NA             0       55
## 9  2009-09-15     1        NA             0       55
## 10 2009-10-15     1        NA             0       55
## ..        ...   ...       ...           ...      ...
```

```r
# Collapse across nurses to create one record per month for Oklahoma County.
dsMonthOklahoma <- dsNurseMonthOklahoma %>%
  dplyr::group_by(CountyID, Month) %>%                   # Split by County & Month into sub-datasets
  dplyr::summarize(                                      # Aggregate/summarize within sub-datasets
    Fte               = sum(Fte, na.rm=T),
    # FmlaHours       = sum(FmlaHours, na.rm=T)
    FteApproximated   = FALSE                            # This variable helps the later union query.
  ) %>%
  dplyr::ungroup()                                       # Unecessary b/c of `summarize()`, but I like the habit.
dsMonthOklahoma
```

```
## Source: local data frame [81 x 4]
## 
##    CountyID      Month   Fte FteApproximated
##       (int)     (date) (dbl)           (lgl)
## 1        55 2009-01-15 17.00           FALSE
## 2        55 2009-02-15 16.76           FALSE
## 3        55 2009-03-15 18.00           FALSE
## 4        55 2009-04-15 17.76           FALSE
## 5        55 2009-05-15 17.52           FALSE
## 6        55 2009-06-15 18.50           FALSE
## 7        55 2009-07-15 18.00           FALSE
## 8        55 2009-08-15 19.00           FALSE
## 9        55 2009-09-15 18.76           FALSE
## 10       55 2009-10-15 17.50           FALSE
## ..      ...        ...   ...             ...
```

```r
# The SQL equivalent to the previous dplyr code.
#   SELECT Month, CountyID, SUM(Fte) as Fte, 'FALSE' AS FteApproximated
#   FROM dsNurseMonthOklahoma
#   GROUP BY Month, CountyID

# The un-piped equivalent to the previous dplyr code.  Notice 3 layers of nesting instead of 3 pipes.
#   dsMonthOklahoma <- dplyr::ungroup(
#     dplyr::summarize(
#       dplyr::group_by(
#         dsNurseMonthOklahoma,
#         CountyID,
#         Month
#       ),
#       # Aggregate/summarize within sub-datasets
#       Fte               = sum(Fte, na.rm=T),
#       # FmlaHours       = sum(FmlaHours, na.rm=T)
#       FteApproximated   = FALSE                            # This variable helps the later union query.
#     )
#   )

rm(dsNurseMonthOklahoma) #Remove this dataset so it's not accidentally used below.

# groom_tulsa -------------------------------------------------------------

# Groom the nurse-month dataset for Tulsa County.
dsMonthTulsa <- dsMonthTulsa %>%
  dplyr::rename_(
    "Month"       = "Month"
    , "Fte"       = "FteSum"
    #, "FmlaHours" = "FmlaSum"
  ) %>%
  dplyr::mutate(
    CountyID            = dsCounty[dsCounty$CountyName=="Tulsa", ]$CountyID,  #Dynamically determine county ID
    Month               = as.Date(Month, "%m/%d/%Y"),
    #FmlaHours          = ifelse(!is.na(FmlaHours), FmlaHours, 0.0)
    FteApproximated    = FALSE
  )  %>%
  dplyr::select(CountyID, Month, Fte, FteApproximated)
dsMonthTulsa
```

```
## Source: local data frame [80 x 4]
## 
##    CountyID      Month   Fte FteApproximated
##       (int)     (date) (dbl)           (lgl)
## 1        72 2009-01-15  25.5           FALSE
## 2        72 2009-02-15  26.5           FALSE
## 3        72 2009-03-15  26.5           FALSE
## 4        72 2009-04-15  26.5           FALSE
## 5        72 2009-05-15  25.5           FALSE
## 6        72 2009-06-15  25.5           FALSE
## 7        72 2009-07-15  25.5           FALSE
## 8        72 2009-08-15  24.5           FALSE
## 9        72 2009-09-15  23.5           FALSE
## 10       72 2009-10-15  23.5           FALSE
## ..      ...        ...   ...             ...
```

```r
# groom_rural -------------------------------------------------------------

# Groom the nurse-month dataset for the 75 rurals counties.
dsNurseMonthRural <- dsNurseMonthRural %>%
  dplyr::rename_(
    "NameFull"            = "Name"
    , "CountyName"        = "HOME_COUNTY"
    , "RegionID"          = "REGIONID"
    , "FtePercent"        = "FTE"
    , "Month"             = "PERIOD"
  ) %>%
  dplyr::select(
    CountyName,
    Month,
    NameFull,
    FtePercent
  ) %>% # dplyr::select(NameFull, Month, CountyName, FtePercent) %>%
  dplyr::filter(!(CountyName %in% countiesToDropFromRural)) %>%
  dplyr::mutate(
    Month      = as.Date(paste0(Month, "-", defaultDayOfMonth), format="%m/%Y-%d"),
    FteString  = gsub("^(\\d{1,3})%\\s+$", "\\1", FtePercent),
    Fte        = .01 * as.numeric(ifelse(nchar(FteString)==0L, 0, FteString)),
    CountyName = car::recode(CountyName, "'Cimmarron'='Cimarron';'Leflore'='Le Flore'")
  ) %>%
  dplyr::arrange(CountyName, Month, NameFull) %>%
  dplyr::select(
    -FtePercent,
    -FteString
  ) %>%
  dplyr::left_join(
    dsCounty[, c("CountyID", "CountyName")], by="CountyName"
  )
dsNurseMonthRural
```

```
## Source: local data frame [3,248 x 5]
## 
##    CountyName      Month           NameFull   Fte CountyID
##         (chr)     (date)              (chr) (dbl)    (int)
## 1       Adair 2012-06-15      Hilda Hypes       1        1
## 2       Adair 2012-08-15      Hilda Hypes       1        1
## 3       Adair 2012-09-15      Hilda Hypes       1        1
## 4       Adair 2012-10-15      Hilda Hypes       1        1
## 5       Adair 2012-12-15      Hilda Hypes       1        1
## 6       Adair 2013-01-15      Hilda Hypes       1        1
## 7       Adair 2013-02-15      Hilda Hypes       1        1
## 8       Adair 2013-03-15      Hilda Hypes       1        1
## 9       Adair 2013-06-15      Hilda Hypes       1        1
## 10      Adair 2015-06-15 Franchesca Futch       1        1
## ..        ...        ...                ...   ...      ...
```

```r
# table(dsNurseMonthRural$CountyID, useNA="always")
# table(dsNurseMonthRural$CountyName, useNA="always")

# Collapse across nurses to create one record per month per county.
dsMonthRural <- dsNurseMonthRural %>%
  dplyr::group_by(CountyID, Month) %>%
  dplyr::summarize(
    Fte                = sum(Fte, na.rm=TRUE),
    # FmlaHours        = sum(FmlaHours, na.rm=TRUE)
    FteApproximated    = FALSE
  ) %>%
  dplyr::ungroup()
dsMonthRural
```

```
## Source: local data frame [1,784 x 4]
## 
##    CountyID      Month   Fte FteApproximated
##       (int)     (date) (dbl)           (lgl)
## 1         1 2012-06-15     1           FALSE
## 2         1 2012-08-15     1           FALSE
## 3         1 2012-09-15     1           FALSE
## 4         1 2012-10-15     1           FALSE
## 5         1 2012-12-15     1           FALSE
## 6         1 2013-01-15     1           FALSE
## 7         1 2013-02-15     1           FALSE
## 8         1 2013-03-15     1           FALSE
## 9         1 2013-06-15     1           FALSE
## 10        1 2015-06-15     1           FALSE
## ..      ...        ...   ...             ...
```

```r
possibleMonths <- seq.Date(range(dsMonthRural$Month)[1], range(dsMonthRural$Month)[2], by="month")
dsPossible <- expand.grid(Month=possibleMonths, CountyID=possibleCountyIDs, stringsAsFactors=F)

#Determine the months were we don't have any rural T&E data.
monthsRuralNotCollected <- (dsMonthRural %>%
  dplyr::right_join(
    dsPossible, by=c("CountyID", "Month")
  ) %>%
  dplyr::group_by(Month) %>%
  dplyr::summarize(
    MeanNA = mean(is.na(Fte))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(MeanNA >= .9999))$Month
monthsRuralNotCollected
```

```
## [1] "2012-07-15" "2012-11-15" "2013-04-15" "2013-05-15" "2013-11-15"
```

```r
rm(dsNurseMonthRural) #Remove this dataset so it's not accidentally used below.
rm(countiesToDropFromRural, defaultDayOfMonth)

# union_all_counties -----------------------------------------------------

# Stack the three datasets on top of each other.
ds <- dsMonthOklahoma %>%
  dplyr::union(
    dsMonthTulsa
  ) %>%
  dplyr::union(
    dsMonthRural
  ) %>%
  dplyr::right_join(
    dsPossible, by=c("CountyID", "Month")
  ) %>%
  dplyr::left_join(
    dsCounty[, c("CountyID", "CountyName", "C1LeadNurseRegion")], by="CountyID"
  ) %>%
  dplyr::rename_("RegionID" = "C1LeadNurseRegion") %>%
  dplyr::arrange(CountyID, Month) %>%
  dplyr::mutate(
    CountyMonthID     = seq_len(n()), # Add the primary key
    Fte               = ifelse(is.na(Fte), 0, Fte),
    MonthMissing      = is.na(FteApproximated),
    FteApproximated   = MonthMissing & (Month %in% monthsRuralNotCollected),
    FteRollingMedian12Month = zoo::rollmedian(x=Fte, 11, na.pad=T, align="right")
  ) %>%
  dplyr::group_by(CountyID) %>%               # Group by county.
  dplyr::mutate(
    CountyAnyMissing  = any(MonthMissing)     # Determine if a county is missing any month
  ) %>%
  dplyr::ungroup()
ds
```

```
## Source: local data frame [3,080 x 10]
## 
##    CountyID      Month   Fte FteApproximated CountyName RegionID
##       (dbl)     (date) (dbl)           (lgl)      (chr)    (int)
## 1         1 2012-06-15     1           FALSE      Adair       11
## 2         1 2012-07-15     0            TRUE      Adair       11
## 3         1 2012-08-15     1           FALSE      Adair       11
## 4         1 2012-09-15     1           FALSE      Adair       11
## 5         1 2012-10-15     1           FALSE      Adair       11
## 6         1 2012-11-15     0            TRUE      Adair       11
## 7         1 2012-12-15     1           FALSE      Adair       11
## 8         1 2013-01-15     1           FALSE      Adair       11
## 9         1 2013-02-15     1           FALSE      Adair       11
## 10        1 2013-03-15     1           FALSE      Adair       11
## ..      ...        ...   ...             ...        ...      ...
## Variables not shown: CountyMonthID (int), MonthMissing (lgl),
##   FteRollingMedian12Month (dbl), CountyAnyMissing (lgl).
```

```r
#Loop through each county to determine which (if any) months need to be approximated.
#   The dataset is small enough that it's not worth vectorizing.
for( countyID in sort(unique(ds$CountyID)) ) {# for( countyID in 13 ) {}
  dsCounty <- dplyr::filter(ds, CountyID==countyID)
  missing <- dsCounty$FteApproximated #is.na(dsCounty$FteApproximated)

  # Attempt to fill in values only for counties missing something.
  if( any(dsCounty$CountyAnyMissing) ) {

    #This statement interpolates missing FTE values
    dsCounty$Fte[missing] <- as.numeric(approx(
      x    = dsCounty$Month[!missing],
      y    = dsCounty$Fte[  !missing],
      xout = dsCounty$Month[ missing]
    )$y)

    #This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if( mean(dsCounty$Fte, na.rm=T) >= thresholdMeanFteToFillIn ) {
      dsCounty$FteApproximated <- (dsCounty$Fte==0)
      dsCounty$Fte <- ifelse(dsCounty$Fte==0, dsCounty$FteRollingMedian12Month, dsCounty$Fte)
    }

    #Overwrite selected values in the real dataset
    ds[ds$CountyID==countyID, ]$Fte             <- dsCounty$Fte
    ds[ds$CountyID==countyID, ]$FteApproximated <- dsCounty$FteApproximated
  }
}
ds
```

```
## Source: local data frame [3,080 x 10]
## 
##    CountyID      Month   Fte FteApproximated CountyName RegionID
##       (dbl)     (date) (dbl)           (lgl)      (chr)    (int)
## 1         1 2012-06-15     1           FALSE      Adair       11
## 2         1 2012-07-15     1            TRUE      Adair       11
## 3         1 2012-08-15     1           FALSE      Adair       11
## 4         1 2012-09-15     1           FALSE      Adair       11
## 5         1 2012-10-15     1           FALSE      Adair       11
## 6         1 2012-11-15     1            TRUE      Adair       11
## 7         1 2012-12-15     1           FALSE      Adair       11
## 8         1 2013-01-15     1           FALSE      Adair       11
## 9         1 2013-02-15     1           FALSE      Adair       11
## 10        1 2013-03-15     1           FALSE      Adair       11
## ..      ...        ...   ...             ...        ...      ...
## Variables not shown: CountyMonthID (int), MonthMissing (lgl),
##   FteRollingMedian12Month (dbl), CountyAnyMissing (lgl).
```

```r
rm(dsMonthOklahoma, dsMonthTulsa, dsMonthRural, dsPossible)  #Remove these datasets so it's not accidentally used below.
rm(possibleMonths, possibleCountyIDs)

# verify_values -----------------------------------------------------------
# Sniff out problems
testit::assert("The Month value must be nonmissing & since 2000", all(!is.na(ds$Month) & (ds$Month>="2012-01-01")))
testit::assert("The CountyID value must be nonmissing & positive.", all(!is.na(ds$CountyID) & (ds$CountyID>0)))
testit::assert("The CountyID value must be in [1, 77].", all(ds$CountyID %in% seq_len(77L)))
testit::assert("The RegionID value must be nonmissing & positive.", all(!is.na(ds$RegionID) & (ds$RegionID>0)))
testit::assert("The RegionID value must be in [1, 20].", all(ds$RegionID %in% seq_len(20L)))
testit::assert("The `Fte` value must be nonmissing & positive.", all(!is.na(ds$Fte) & (ds$Fte>=0)))
# testit::assert("The `FmlaHours` value must be nonmissing & nonnegative", all(is.na(ds$FmlaHours) | (ds$FmlaHours>=0)))

testit::assert("The County-Month combination should be unique.", all(!duplicated(paste(ds$CountyID, ds$Month))))
testit::assert("The Region-County-Month combination should be unique.", all(!duplicated(paste(ds$RegionID, ds$CountyID, ds$Month))))
table(paste(ds$CountyID, ds$Month))[table(paste(ds$CountyID, ds$Month))>1]
```

```
## named integer(0)
```

```r
# specify_columns_to_upload -----------------------------------------------
columnsToWrite <- c( "CountyMonthID", "CountyID", "Month", "Fte", "FteApproximated", "RegionID")
dsSlim <- ds[, columnsToWrite]
dsSlim$FteApproximated <- as.integer(dsSlim$FteApproximated)
dsSlim
```

```
## Source: local data frame [3,080 x 6]
## 
##    CountyMonthID CountyID      Month   Fte FteApproximated RegionID
##            (int)    (dbl)     (date) (dbl)           (int)    (int)
## 1              1        1 2012-06-15     1               0       11
## 2              2        1 2012-07-15     1               1       11
## 3              3        1 2012-08-15     1               0       11
## 4              4        1 2012-09-15     1               0       11
## 5              5        1 2012-10-15     1               0       11
## 6              6        1 2012-11-15     1               1       11
## 7              7        1 2012-12-15     1               0       11
## 8              8        1 2013-01-15     1               0       11
## 9              9        1 2013-02-15     1               0       11
## 10            10        1 2013-03-15     1               0       11
## ..           ...      ...        ...   ...             ...      ...
```

```r
# # upload_to_db ------------------------------------------------------------
# (startTime <- Sys.time())
# dbTable <- "Osdh.tblC1TEMonth"
# channel <- RODBC::odbcConnect("te-example") #getSqlTypeInfo("Microsoft SQL Server") #;odbcGetInfo(channel)
#
# columnInfo <- RODBC::sqlColumns(channel, dbTable)
# varTypes <- as.character(columnInfo$TYPE_NAME)
# names(varTypes) <- as.character(columnInfo$COLUMN_NAME)  #varTypes
#
# RODBC::sqlClear(channel, dbTable)
# RODBC::sqlSave(channel, dsSlim, dbTable, append=TRUE, rownames=FALSE, fast=TRUE, varTypes=varTypes)
# RODBC::odbcClose(channel)
# rm(columnInfo, channel, columnsToWrite, dbTable, varTypes)
# (elapsedDuration <-  Sys.time() - startTime) #21.4032 secs 2015-10-31

# save_to_disk ------------------------------------------------------------
readr::write_csv(ds, pathOutUnified)

# inspect -----------------------------------------------------------------
library(ggplot2)

# Graph each county-month
ggplot(ds, aes(x=Month, y=Fte, group=factor(CountyID), color=factor(CountyID), shape=FteApproximated, ymin=0)) +
  geom_point(position=position_jitter(height=.05, width=5), size=4, na.rm=T) +
  # geom_text(aes(label=CountyMonthID)) +
  geom_line(position=position_jitter(height=.1, width=5)) +
  scale_shape_manual(values=c("TRUE"=21, "FALSE"=NA)) +
  theme_light() +
  guides(color = guide_legend(ncol=4, override.aes = list(size=3, alpha = 1))) +
  guides(shape = guide_legend(ncol=2, override.aes = list(size=3, alpha = 1))) +
  labs(title="FTE sum each month (by county)", y="Sum of FTE for County")
```

<img src="figure/te-ellis-Rmdauto-report-1.png" title="plot of chunk auto-report" alt="plot of chunk auto-report" style="display: block; margin: auto;" />

```r
# Graph each region-month
dsRegion <- ds %>%
  dplyr::group_by(RegionID, Month) %>%
  dplyr::summarize(
    Fte             = sum(Fte, na.rm=T),
    FteApproximated = any(FteApproximated)
  ) %>%
  dplyr::ungroup()

last_plot() %+%
  dsRegion +
  aes(group=factor(RegionID), color=factor(RegionID))
```

<img src="figure/te-ellis-Rmdauto-report-2.png" title="plot of chunk auto-report" alt="plot of chunk auto-report" style="display: block; margin: auto;" />

```r
# last_plot() +
#   aes(y=FmlaHours) +
#   labs(title="FmlaHours sum each month (by county)")
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.2.2 (2015-08-14)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 14.04.3 LTS
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] RODBC_1.3-12  magrittr_1.5  ggplot2_1.0.1
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.2        formatR_1.2.1      nloptr_1.0.4      
##  [4] plyr_1.8.3         tools_3.2.2        digest_0.6.8      
##  [7] lme4_1.1-10        evaluate_0.8       gtable_0.1.2      
## [10] nlme_3.1-122       lattice_0.20-33    mgcv_1.8-9        
## [13] Matrix_1.2-2       DBI_0.3.1.9008     parallel_3.2.2    
## [16] SparseM_1.7        proto_0.3-10       dplyr_0.4.3.9000  
## [19] stringr_1.0.0.9000 knitr_1.11.3       MatrixModels_0.4-1
## [22] grid_3.2.2         nnet_7.3-11        R6_2.1.1          
## [25] minqa_1.2.4        reshape2_1.4.1     readr_0.2.2       
## [28] car_2.1-0          scales_0.3.0       MASS_7.3-45       
## [31] splines_3.2.2      assertthat_0.1     pbkrtest_0.4-2    
## [34] testit_0.4         colorspace_1.2-6   labeling_0.3      
## [37] quantreg_5.19      stringi_1.0-1      lazyeval_0.1.10   
## [40] munsell_0.4.2      markdown_0.7.7     zoo_1.7-12
```

```r
Sys.time()
```

```
## [1] "2015-11-30 20:49:42 CST"
```

