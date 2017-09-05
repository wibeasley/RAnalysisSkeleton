



This report was automatically generated with the R package **knitr**
(version 1.17).


```r
# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./stitched-output/manipulation/te-ellis.md") # dir.create("./stitched-output/manipulation/", recursive=T)
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
```

```r
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
```

```r
# Attach these package(s) so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr            , quietly=TRUE)
library(DBI                 , quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"        )
requireNamespace("tidyr"        )
requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"       ) # For asserting conditions meet expected patterns.
requireNamespace("checkmate"    ) # For asserting conditions meet expected patterns. # devtools::install_github("mllg/checkmate")
requireNamespace("RSQLite"      ) # Lightweight database for non-PHI data.
# requireNamespace("RODBC"      ) # For communicating with SQL Server over a locally-configured DSN.  Uncomment if you use 'upload-to-db' chunk.
requireNamespace("OuhscMunge") #devtools::install_github(repo="OuhscBbmc/OuhscMunge")
```

```r
# Constant values that won't change.
path_out_unified               <- "data-public/derived/county-month-te.csv"
path_db                        <- "data-unshared/derived/te.sqlite3"
counties_to_drop_from_rural    <- c("Central Office", "Tulsa", "Oklahoma") #Exclude these records from the rural dataset.
default_day_of_month           <- 15L      # Summarize each month at its (rough) midpoint.
possible_county_ids            <- 1:77     #There are 77 counties.
threshold_mean_fte_t_fill_in   <- 10L      #Any county averaging over 10 hours can be filled in with its mean.
figure_path <- 'stitched-output/manipulation/te/'

# URIs of CSV and County lookup table
path_in_oklahoma  <- "./data-public/raw/te/nurse-month-oklahoma.csv"
path_in_tulsa     <- "./data-public/raw/te/month-tulsa.csv"
path_in_rural     <- "./data-public/raw/te/nurse-month-rural.csv"
path_county       <- "./data-public/raw/te/county.csv"

col_types_oklahoma <- readr::cols_only(
  `Employee..`          = readr::col_integer(),
  `Year`                = readr::col_integer(),
  `Month`               = readr::col_integer(),
  `FTE`                 = readr::col_double(),
  `FMLA.Hours`          = readr::col_integer(),
  `Training.Hours`      = readr::col_integer(),
  `Name`                = readr::col_character()
)

col_types_tulsa <- readr::cols_only(
  Month                 = readr::col_date("%m/%d/%Y"),
  FteSum                = readr::col_double(),
  FmlaSum               = readr::col_integer()
)

col_types_rural <- readr::cols_only(
  HOME_COUNTY           = readr::col_character(),
  FTE                   = readr::col_character(),  # Force as a character.
  PERIOD                = readr::col_character(),
  EMPLOYEEID            = readr::col_integer(),
  REGIONID              = readr::col_integer(),
  Name                  = readr::col_character()
)

col_types_county <- readr::cols_only(
  CountyID              = readr::col_integer(),
  CountyName            = readr::col_character(),
  GeoID                 = readr::col_integer(),
  FipsCode              = readr::col_integer(),
  FundingC1             = readr::col_integer(),
  FundingOcap           = readr::col_integer(),
  C1LeadNurseRegion     = readr::col_integer(),
  C1LeadNurseName       = readr::col_character(),
  Urban                 = readr::col_integer(),
  LabelLongitude        = readr::col_double(),
  LabelLatitude         = readr::col_double(),
  MiechvEvaluation      = readr::col_integer(),
  MiechvFormula         = readr::col_integer()
)

# readr::spec_csv(path_in_oklahoma)
# readr::spec_csv(path_in_tulsa   )
# readr::spec_csv(path_in_rural   )
# readr::spec_csv(path_county     )
```

```r
# Read the CSVs
ds_nurse_month_oklahoma <- readr::read_csv(path_in_oklahoma   , col_types=col_types_oklahoma)
ds_month_tulsa          <- readr::read_csv(path_in_tulsa      , col_types=col_types_tulsa)
ds_nurse_month_rural    <- readr::read_csv(path_in_rural      , col_types=col_types_rural)
ds_county               <- readr::read_csv(path_county        , col_types=col_types_county)

rm(path_in_oklahoma, path_in_tulsa, path_in_rural, path_county)
rm(col_types_oklahoma, col_types_tulsa, col_types_rural, col_types_county)

# Print the first few rows of each table, especially if you're stitching with knitr (see first line of this file).
#   If you print, make sure that the datasets don't contain any PHI.
#   A normal `data.frame` will print all rows.  But `readr::read_csv()` returns a `tibble::tibble`,
#   which prints only the first 10 rows by default.  It also lists the data type of each column.
ds_nurse_month_oklahoma
```

```
## # A tibble: 1,480 x 7
##    Employee..  Year Month   FTE FMLA.Hours Training.Hours          Name
##         <int> <int> <int> <dbl>      <int>          <int>         <chr>
##  1          1  2009     1     1         NA             NA Akilah Amyx  
##  2          1  2009     2     1         NA             NA Akilah Amyx  
##  3          1  2009     3     1         NA             NA Akilah Amyx  
##  4          1  2009     4     1         NA             NA Akilah Amyx  
##  5          1  2009     5     1         NA             NA Akilah Amyx  
##  6          1  2009     6     1         NA             NA Akilah Amyx  
##  7          1  2009     7     1         NA             NA Akilah Amyx  
##  8          1  2009     8     1         NA             32 Akilah Amyx  
##  9          1  2009     9     1         NA             NA Akilah Amyx  
## 10          1  2009    10     1         NA             NA Akilah Amyx  
## # ... with 1,470 more rows
```

```r
ds_month_tulsa
```

```
## # A tibble: 80 x 3
##         Month FteSum FmlaSum
##        <date>  <dbl>   <int>
##  1 2009-01-15   25.5      NA
##  2 2009-02-15   26.5      NA
##  3 2009-03-15   26.5     274
##  4 2009-04-15   26.5      NA
##  5 2009-05-15   25.5     112
##  6 2009-06-15   25.5      NA
##  7 2009-07-15   25.5      NA
##  8 2009-08-15   24.5      51
##  9 2009-09-15   23.5      NA
## 10 2009-10-15   23.5      NA
## # ... with 70 more rows
```

```r
ds_nurse_month_rural
```

```
## # A tibble: 4,726 x 6
##     HOME_COUNTY   FTE  PERIOD EMPLOYEEID REGIONID            Name
##           <chr> <chr>   <chr>      <int>    <int>           <chr>
##  1 Pottawatomie 100 % 06/2012         46       49 Cheree Crites  
##  2 Pottawatomie 100 % 08/2012         46       49 Cheree Crites  
##  3 Pottawatomie 100 % 09/2012         46       49 Cheree Crites  
##  4 Pottawatomie 100 % 10/2012         46       49 Cheree Crites  
##  5 Pottawatomie 100 % 12/2012         46       49 Cheree Crites  
##  6 Pottawatomie 100 % 01/2013         46       49 Cheree Crites  
##  7 Pottawatomie 100 % 02/2013         46       49 Cheree Crites  
##  8     Oklahoma 100 % 08/2012         47       44 Cheryll Canez  
##  9     Oklahoma 100 % 09/2012         47       44 Cheryll Canez  
## 10     Oklahoma 100 % 10/2012         47       44 Cheryll Canez  
## # ... with 4,716 more rows
```

```r
ds_county
```

```
## # A tibble: 77 x 13
##    CountyID CountyName GeoID FipsCode FundingC1 FundingOcap
##       <int>      <chr> <int>    <int>     <int>       <int>
##  1        1      Adair 40001        1         1           0
##  2        2    Alfalfa 40003        3         0           0
##  3        3      Atoka 40005        5         1           0
##  4        4     Beaver 40007        7         0           0
##  5        5    Beckham 40009        9         1           0
##  6        6     Blaine 40011       11         1           0
##  7        7      Bryan 40013       13         1           0
##  8        8      Caddo 40015       15         1           0
##  9        9   Canadian 40017       17         1           0
## 10       10     Carter 40019       19         1           0
## # ... with 67 more rows, and 7 more variables: C1LeadNurseRegion <int>,
## #   C1LeadNurseName <chr>, Urban <int>, LabelLongitude <dbl>,
## #   LabelLatitude <dbl>, MiechvEvaluation <int>, MiechvFormula <int>
```

```r
# OuhscMunge::column_rename_headstart(ds_county) #Spit out columns to help write call ato `dplyr::rename()`.
ds_county <- ds_county %>%
  dplyr::select_( #`select()` implicitly drops the other columns not mentioned.
    "county_id"     = "CountyID",
    "county_name"   = "CountyName",
    "region_id"     = "C1LeadNurseRegion"
  )
```

```r
# Sanitize illegal variable names if desired: colnames(ds_nurse_month_oklahoma) <- make.names(colnames(ds_nurse_month_oklahoma))
# OuhscMunge::column_rename_headstart(ds_nurse_month_oklahoma)

# Groom the nurse-month dataset for Oklahoma County.
ds_nurse_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::select_(
    # "employee_number"           = "`Employee..`"          # Used to be "Employee #" before sanitizing. Drop b/c unnecessary.
    # , "employee_name"           = "`Name`"
    "year"                        = "`Year`"
    , "month"                     = "`Month`"
    , "fte"                       = "`FTE`"
    , "fmla_hours"                = "`FMLA.Hours`"          # Used to be "FMLA Hours" before sanitizing.
    , "training_hours"            = "`Training.Hours`"      # Used to be "Training Hours" before sanitizing.
  ) %>%
  dplyr::mutate(
    county_id         = ds_county[ds_county$county_name=="Oklahoma", ]$county_id,        # Dynamically determine county ID.
    month             = as.Date(ISOdate(year, month, default_day_of_month)),             # Combine fields for one date.
    # fmla_hours      = dplyr::if_else(!is.na(fmla_hours), fmla_hours, 0L),              # Set missing values to zero.
    training_hours    = dplyr::coalesce(training_hours, 0L)                              # Set missing values to zero.
    # training_hours  = dplyr::if_else(!is.na(training_hours), training_hours, 0L)       # Set missing values to zero.
  ) %>%
  dplyr::select(      # Drop unecessary variables (ie, defensive programming)
    -year
  )
ds_nurse_month_oklahoma
```

```
## # A tibble: 1,480 x 5
##         month   fte fmla_hours training_hours county_id
##        <date> <dbl>      <int>          <int>     <int>
##  1 2009-01-15     1         NA              0        55
##  2 2009-02-15     1         NA              0        55
##  3 2009-03-15     1         NA              0        55
##  4 2009-04-15     1         NA              0        55
##  5 2009-05-15     1         NA              0        55
##  6 2009-06-15     1         NA              0        55
##  7 2009-07-15     1         NA              0        55
##  8 2009-08-15     1         NA             32        55
##  9 2009-09-15     1         NA              0        55
## 10 2009-10-15     1         NA              0        55
## # ... with 1,470 more rows
```

```r
# Collapse across nurses to create one record per month for Oklahoma County.
ds_month_oklahoma <- ds_nurse_month_oklahoma %>%
  dplyr::group_by(county_id, month) %>%                  # Split by County & month into sub-datasets
  dplyr::summarize(                                      # Aggregate/summarize within sub-datasets
    fte                = sum(fte, na.rm=T),
    # fmla_hours       = sum(fmla_hours, na.rm=T)
    fte_approximated   = FALSE                           # This variable helps the later union query.
  ) %>%
  dplyr::ungroup()                                       # Unecessary b/c of `summarize()`, but I like the habit.
ds_month_oklahoma
```

```
## # A tibble: 81 x 4
##    county_id      month   fte fte_approximated
##        <int>     <date> <dbl>            <lgl>
##  1        55 2009-01-15 17.00            FALSE
##  2        55 2009-02-15 17.00            FALSE
##  3        55 2009-03-15 17.00            FALSE
##  4        55 2009-04-15 17.50            FALSE
##  5        55 2009-05-15 18.76            FALSE
##  6        55 2009-06-15 18.50            FALSE
##  7        55 2009-07-15 18.00            FALSE
##  8        55 2009-08-15 18.50            FALSE
##  9        55 2009-09-15 19.00            FALSE
## 10        55 2009-10-15 18.76            FALSE
## # ... with 71 more rows
```

```r
# The SQL equivalent to the previous dplyr code.
#   SELECT month, county_id, SUM(fte) as fte, 'FALSE' AS fte_approximated
#   FROM ds_nurse_month_oklahoma
#   GROUP BY month, county_id

# The un-piped equivalent to the previous dplyr code.  Notice 3 layers of nesting instead of 3 pipes.
#   ds_month_oklahoma <- dplyr::ungroup(
#     dplyr::summarize(
#       dplyr::group_by(
#         ds_nurse_month_oklahoma,
#         county_id,
#         month
#       ),
#       # Aggregate/summarize within sub-datasets
#       fte               = sum(fte, na.rm=T),
#       # fmla_hours       = sum(fmla_hours, na.rm=T)
#       fte_approximated   = FALSE                            # This variable helps the later union query.
#     )
#   )

rm(ds_nurse_month_oklahoma) #Remove this dataset so it's not accidentally used below.
```

```r
# Groom the nurse-month dataset for Tulsa County.
# OuhscMunge::column_rename_headstart(ds_month_tulsa)
ds_month_tulsa <- ds_month_tulsa %>%
  dplyr::select_(
    "month"             = "`Month`"
    , "fte"             = "`FteSum`"
    , "fmla_sum"        = "`FmlaSum`"
  ) %>%
  dplyr::mutate(
    county_id           = ds_county[ds_county$county_name=="Tulsa", ]$county_id,  #Dynamically determine county ID
    #fmla_hours         = ifelse(!is.na(fmla_hours), fmla_hours, 0.0)
    fte_approximated    = FALSE
  )  %>%
  dplyr::select(county_id, month, fte, fte_approximated)
ds_month_tulsa
```

```
## # A tibble: 80 x 4
##    county_id      month   fte fte_approximated
##        <int>     <date> <dbl>            <lgl>
##  1        72 2009-01-15  25.5            FALSE
##  2        72 2009-02-15  26.5            FALSE
##  3        72 2009-03-15  26.5            FALSE
##  4        72 2009-04-15  26.5            FALSE
##  5        72 2009-05-15  25.5            FALSE
##  6        72 2009-06-15  25.5            FALSE
##  7        72 2009-07-15  25.5            FALSE
##  8        72 2009-08-15  24.5            FALSE
##  9        72 2009-09-15  23.5            FALSE
## 10        72 2009-10-15  23.5            FALSE
## # ... with 70 more rows
```

```r
# Groom the nurse-month dataset for the 75 rural counties.
OuhscMunge::column_rename_headstart(ds_nurse_month_rural)
```

```
## , "home_county"            = "`HOME_COUNTY`"
##  , "fte"                    = "`FTE`"
##  , "period"                 = "`PERIOD`"
##  , "employeeid"             = "`EMPLOYEEID`"
##  , "regionid"               = "`REGIONID`"
##  , "name"                   = "`Name`"
```

```r
ds_nurse_month_rural <- ds_nurse_month_rural %>%
  dplyr::select_(
    "name_full"                 = "`Name`"
    , "county_name"             = "`HOME_COUNTY`"
    , "fte_percent"             = "`FTE`"
    , "month"                   = "`PERIOD`"
    # , "employee_id"           = "`EMPLOYEEID`"    # Not needed
    # , "region_id              = "`REGIONID`"      # Not needed
  ) %>%
  dplyr::select(
    county_name,
    month,
    name_full,
    fte_percent
  ) %>% # dplyr::select(name_full, month, county_name, fte_percent) %>%
  dplyr::filter(!(county_name %in% counties_to_drop_from_rural)) %>%
  dplyr::mutate(
    month       = as.Date(paste0(month, "-", default_day_of_month), format="%m/%Y-%d"),
    fte_string  = gsub("^(\\d{1,3})\\s*%$", "\\1", fte_percent),                           # Extract digits before the '%' sign.
    fte         = .01 * as.numeric(ifelse(nchar(fte_string)==0L, 0, fte_string)),
    county_name = dplyr::recode(county_name, `Cimmarron`='Cimarron', `Leflore`='Le Flore') # Or consider `car::recode()`.
  ) %>%
  dplyr::arrange(county_name, month, name_full) %>%
  dplyr::select(
    -fte_percent,
    -fte_string
  ) %>%
  dplyr::left_join(
    ds_county[, c("county_id", "county_name")], by="county_name"
  )
ds_nurse_month_rural
```

```
## # A tibble: 3,248 x 5
##    county_name      month          name_full   fte county_id
##          <chr>     <date>              <chr> <dbl>     <int>
##  1       Adair 2012-06-15      Hilda Hypes     1.0         1
##  2       Adair 2012-08-15      Hilda Hypes     1.0         1
##  3       Adair 2012-09-15      Hilda Hypes     0.5         1
##  4       Adair 2012-10-15      Hilda Hypes     1.0         1
##  5       Adair 2012-12-15      Hilda Hypes     1.0         1
##  6       Adair 2013-01-15      Hilda Hypes     1.0         1
##  7       Adair 2013-02-15      Hilda Hypes     1.0         1
##  8       Adair 2013-03-15      Hilda Hypes     0.5         1
##  9       Adair 2013-06-15      Hilda Hypes     1.0         1
## 10       Adair 2015-06-15 Franchesca Futch     1.0         1
## # ... with 3,238 more rows
```

```r
# table(ds_nurse_month_rural$county_id, useNA="always")
# table(ds_nurse_month_rural$county_name, useNA="always")

# Collapse across nurses to create one record per month per county.
ds_month_rural <- ds_nurse_month_rural %>%
  dplyr::group_by(county_id, month) %>%
  dplyr::summarize(
    fte                 = sum(fte, na.rm=TRUE),
    # fmla_hours        = sum(fmla_hours, na.rm=TRUE)
    fte_approximated    = FALSE
  ) %>%
  dplyr::ungroup()
ds_month_rural
```

```
## # A tibble: 1,784 x 4
##    county_id      month   fte fte_approximated
##        <int>     <date> <dbl>            <lgl>
##  1         1 2012-06-15   1.0            FALSE
##  2         1 2012-08-15   1.0            FALSE
##  3         1 2012-09-15   0.5            FALSE
##  4         1 2012-10-15   1.0            FALSE
##  5         1 2012-12-15   1.0            FALSE
##  6         1 2013-01-15   1.0            FALSE
##  7         1 2013-02-15   1.0            FALSE
##  8         1 2013-03-15   0.5            FALSE
##  9         1 2013-06-15   1.0            FALSE
## 10         1 2015-06-15   1.0            FALSE
## # ... with 1,774 more rows
```

```r
# Consider replacing a join with ds_possible with a call to tidyr::complete(), if you can guarantee each month shows up at least once.
ds_possible <- tidyr::crossing(
  month     = seq.Date(range(ds_month_rural$month)[1], range(ds_month_rural$month)[2], by="month"),
  county_id = possible_county_ids
)

# Determine the months were we don't have any rural T&E data.
months_rural_not_collected <- ds_month_rural %>%
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) %>%
  dplyr::group_by(month) %>%
  dplyr::summarize(
    mean_na = mean(is.na(fte))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(mean_na >= .9999) %>%
  dplyr::pull(month)
months_rural_not_collected
```

```
## [1] "2012-07-15" "2012-11-15" "2013-04-15" "2013-05-15" "2013-11-15"
```

```r
rm(ds_nurse_month_rural) #Remove this dataset so it's not accidentally used below.
rm(counties_to_drop_from_rural, default_day_of_month)
```

```r
# Stack the three datasets on top of each other.
ds <- ds_month_oklahoma %>%
  dplyr::union(ds_month_tulsa) %>%
  dplyr::union(ds_month_rural) %>%
  dplyr::right_join(
    ds_possible, by=c("county_id", "month")
  ) %>%
  dplyr::left_join(
    ds_county, by="county_id"
  ) %>%
  dplyr::arrange(county_id, month) %>%
  dplyr::mutate(
    county_month_id             = seq_len(n()), # Add the primary key
    fte                         = dplyr::coalesce(fte, 0),
    month_missing               = is.na(fte_approximated),
    fte_approximated            = month_missing & (month %in% months_rural_not_collected),
    fte_rolling_median_11_month = zoo::rollmedian(x=fte, 11, na.pad=T, align="right")
  ) %>%
  dplyr::group_by(county_id) %>%               # Group by county.
  dplyr::mutate(
    county_any_missing  = any(month_missing)     # Determine if a county is missing any month
  ) %>%
  dplyr::ungroup()
ds
```

```
## # A tibble: 3,080 x 10
##    county_id      month   fte fte_approximated county_name region_id
##        <int>     <date> <dbl>            <lgl>       <chr>     <int>
##  1         1 2012-06-15   1.0            FALSE       Adair        11
##  2         1 2012-07-15   0.0             TRUE       Adair        11
##  3         1 2012-08-15   1.0            FALSE       Adair        11
##  4         1 2012-09-15   0.5            FALSE       Adair        11
##  5         1 2012-10-15   1.0            FALSE       Adair        11
##  6         1 2012-11-15   0.0             TRUE       Adair        11
##  7         1 2012-12-15   1.0            FALSE       Adair        11
##  8         1 2013-01-15   1.0            FALSE       Adair        11
##  9         1 2013-02-15   1.0            FALSE       Adair        11
## 10         1 2013-03-15   0.5            FALSE       Adair        11
## # ... with 3,070 more rows, and 4 more variables: county_month_id <int>,
## #   month_missing <lgl>, fte_rolling_median_11_month <dbl>,
## #   county_any_missing <lgl>
```

```r
#Loop through each county to determine which (if any) months need to be approximated.
#   The dataset is small enough that it's not worth vectorizing.
for( id in sort(unique(ds$county_id)) ) {# for( id in 13 ) {}
  ds_county_approx <- dplyr::filter(ds, county_id==id)
  missing          <- ds_county_approx$fte_approximated #is.na(ds_county_approx$fte_approximated)

  # Attempt to fill in values only for counties missing something.
  if( any(ds_county_approx$county_any_missing) ) {

    # This statement interpolates missing FTE values
    ds_county_approx$fte[missing] <- as.numeric(approx(
      x    = ds_county_approx$month[!missing],
      y    = ds_county_approx$fte[  !missing],
      xout = ds_county_approx$month[ missing]
    )$y)

    # This statement extrapolates missing FTE values, which occurs when the first/last few months are missing.
    if( mean(ds_county_approx$fte, na.rm=T) >= threshold_mean_fte_t_fill_in ) {
      ds_county_approx$fte_approximated <- (ds_county_approx$fte==0)
      ds_county_approx$fte              <- ifelse(ds_county_approx$fte==0, ds_county_approx$fte_rolling_median_11_month, ds_county_approx$fte)
    }

    # Overwrite selected values in the real dataset
    ds[ds$county_id==id, ]$fte              <- ds_county_approx$fte
    ds[ds$county_id==id, ]$fte_approximated <- ds_county_approx$fte_approximated
  }
}
ds
```

```
## # A tibble: 3,080 x 10
##    county_id      month   fte fte_approximated county_name region_id
##        <int>     <date> <dbl>            <lgl>       <chr>     <int>
##  1         1 2012-06-15   1.0            FALSE       Adair        11
##  2         1 2012-07-15   1.0             TRUE       Adair        11
##  3         1 2012-08-15   1.0            FALSE       Adair        11
##  4         1 2012-09-15   0.5            FALSE       Adair        11
##  5         1 2012-10-15   1.0            FALSE       Adair        11
##  6         1 2012-11-15   1.0             TRUE       Adair        11
##  7         1 2012-12-15   1.0            FALSE       Adair        11
##  8         1 2013-01-15   1.0            FALSE       Adair        11
##  9         1 2013-02-15   1.0            FALSE       Adair        11
## 10         1 2013-03-15   0.5            FALSE       Adair        11
## # ... with 3,070 more rows, and 4 more variables: county_month_id <int>,
## #   month_missing <lgl>, fte_rolling_median_11_month <dbl>,
## #   county_any_missing <lgl>
```

```r
rm(ds_month_oklahoma, ds_month_tulsa, ds_month_rural, ds_possible)  #Remove these datasets so it's not accidentally used below.
rm(possible_county_ids)
```

```r
# Sniff out problems
checkmate::assert_integer(ds$county_month_id    , lower=          1L              , any.missing=F, unique=T)
checkmate::assert_integer(ds$county_id          , lower=          1L   , upper=77L, any.missing=F, unique=F)
checkmate::assert_date(   ds$month              , lower="2012-01-01"              , any.missing=F)
checkmate::assert_integer(ds$region_id          , lower=          1L   , upper=20L, any.missing=F)
checkmate::assert_numeric(ds$fte                , lower=          0    , upper=40L, any.missing=F)
checkmate::assert_logical(ds$fte_approximated                                     , any.missing=F)

county_month_combo   <- paste(ds$county_id, ds$month)
# Light way to test combination
checkmate::assert_character(county_month_combo, min.chars=8            , any.missing=F, unique=T)
# Vigilant way to test combination
checkmate::assert_character(county_month_combo, pattern  ="^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$"            , any.missing=F, unique=T)

# # Two ways to diagnose/identify bad patterns
# which(!grepl("^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", county_month_combo))                  # Ideally this is an empty set (ie, `integer(0)`)
# county_month_combo[!grepl("^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", county_month_combo)]     # Ideally this is an empty set (ie, `chracter(0)`)
#
# # Two ways to diagnose/identify bad patterns duplicates
# which(duplicated(county_month_combo))                                                 # Ideally this is an empty set (ie, `integer(0)`)
# county_month_combo[!grepl("^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", county_month_combo)]     # Ideally this is an empty set (ie, `chracter(0)`)


# Alternative ways to test & diagnose unique combintations.
# testit::assert("The County-month combination should be unique.", all(!duplicated(paste(ds$county_id, ds$month))))
# testit::assert("The Region-County-month combination should be unique.", all(!duplicated(paste(ds$region_id, ds$county_id, ds$month))))
# table(paste(ds$county_id, ds$month))[table(paste(ds$county_id, ds$month))>1]
```

```r
# dput(colnames(ds)) # Print colnames for line below.
columns_to_write <- c(
  "county_month_id", "county_id",
  "month", "fte", "fte_approximated",
  "region_id"
)
ds_slim <- ds %>%
  dplyr::select_(.dots=columns_to_write) %>%
  # dplyr::slice(1:100) %>%
  dplyr::mutate(
    fte_approximated <- as.integer(fte_approximated)
  )
ds_slim
```

```
## # A tibble: 3,080 x 7
##    county_month_id county_id      month   fte fte_approximated region_id
##              <int>     <int>     <date> <dbl>            <lgl>     <int>
##  1               1         1 2012-06-15   1.0            FALSE        11
##  2               2         1 2012-07-15   1.0             TRUE        11
##  3               3         1 2012-08-15   1.0            FALSE        11
##  4               4         1 2012-09-15   0.5            FALSE        11
##  5               5         1 2012-10-15   1.0            FALSE        11
##  6               6         1 2012-11-15   1.0             TRUE        11
##  7               7         1 2012-12-15   1.0            FALSE        11
##  8               8         1 2013-01-15   1.0            FALSE        11
##  9               9         1 2013-02-15   1.0            FALSE        11
## 10              10         1 2013-03-15   0.5            FALSE        11
## # ... with 3,070 more rows, and 1 more variables: `fte_approximated <-
## #   as.integer(fte_approximated)` <int>
```

```r
rm(columns_to_write)
```

```r
# If there's no PHI, a rectangular CSV is usually adequate, and it's portable to other machines and software.
readr::write_csv(ds, path_out_unified)
# readr::write_rds(ds, path_out_unified, compress="gz") # Save as a compressed R-binary file if it's large or has a lot of factors.
```

```r
# If there's no PHI, a local database like SQLite fits a nice niche if
#   * the data is relational and
#   * later, only portions need to be queried/retrieved at a time (b/c everything won't need to be loaded into R's memory)

sql_create_tbl_county <- "
  CREATE TABLE `tbl_county` (
  	county_id              INTEGER NOT NULL PRIMARY KEY,
    county_name            VARCHAR NOT NULL,
    region_id              INTEGER NOT NULL
  );"

sql_create_tbl_te_month <- "
  CREATE TABLE `tbl_te_month` (
  	county_month_id                    INTEGER NOT NULL PRIMARY KEY,
  	county_id                          INTEGER NOT NULL,
    month                              VARCHAR NOT NULL,         -- There's no date type in SQLite.  Make sure it's ISO8601: yyyy-mm-dd
    fte                                REAL    NOT NULL,
    fte_approximated                   REAL    NOT NULL,
    month_missing                      INTEGER NOT NULL,         -- There's no bit/boolean type in SQLite
    fte_rolling_median_11_month        INTEGER, --  NOT NULL

    FOREIGN KEY(county_id) REFERENCES tbl_county(county_id)
  );"

# Remove old DB
if( file.exists(path_db) ) file.remove(path_db)
```

```
## [1] TRUE
```

```r
# Open connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
RSQLite::dbSendQuery(cnn, "PRAGMA foreign_keys=ON;") #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
```

```
## <SQLiteResult>
##   SQL  PRAGMA foreign_keys=ON;
##   ROWS Fetched: 0 [complete]
##        Changed: 0
```

```r
dbListTables(cnn)
```

```
## Warning: Closing open result set, pending rows
```

```
## character(0)
```

```r
# Create tables
dbSendQuery(cnn, sql_create_tbl_county)
```

```
## <SQLiteResult>
##   SQL  
##   CREATE TABLE `tbl_county` (
##   	county_id              INTEGER NOT NULL PRIMARY KEY,
##     county_name            VARCHAR NOT NULL,
##     region_id              INTEGER NOT NULL
##   );
##   ROWS Fetched: 0 [complete]
##        Changed: 0
```

```r
dbSendQuery(cnn, sql_create_tbl_te_month)
```

```
## Warning: Closing open result set, pending rows
```

```
## <SQLiteResult>
##   SQL  
##   CREATE TABLE `tbl_te_month` (
##   	county_month_id                    INTEGER NOT NULL PRIMARY KEY,
##   	county_id                          INTEGER NOT NULL,
##     month                              VARCHAR NOT NULL,         -- There's no date type in SQLite.  Make sure it's ISO8601: yyyy-mm-dd
##     fte                                REAL    NOT NULL,
##     fte_approximated                   REAL    NOT NULL,
##     month_missing                      INTEGER NOT NULL,         -- There's no bit/boolean type in SQLite
##     fte_rolling_median_11_month        INTEGER, --  NOT NULL
## 
##     FOREIGN KEY(county_id) REFERENCES tbl_county(county_id)
##   );
##   ROWS Fetched: 0 [complete]
##        Changed: 0
```

```r
dbListTables(cnn)
```

```
## Warning: Closing open result set, pending rows
```

```
## [1] "tbl_county"   "tbl_te_month"
```

```r
# Write to database
dbWriteTable(cnn, name='tbl_county',              value=ds_county,        append=TRUE, row.names=FALSE)
ds %>%
  dplyr::mutate(
    month               = strftime(month, "%Y-%m-%d"),
    fte_approximated    = as.logical(fte_approximated),
    month_missing       = as.logical(month_missing)
  ) %>%
  dplyr::select(county_month_id, county_id, month, fte, fte_approximated, month_missing, fte_rolling_median_11_month) %>%
  dbWriteTable(value=., conn=cnn, name='tbl_te_month', append=TRUE, row.names=FALSE)

# Close connection
dbDisconnect(cnn)

# # ---- upload-to-db ----------------------------------------------------------
# If there's PHI, write to a central database server that authenticates users (like SQL Server).
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


#Possibly consider writing to sqlite (with RSQLite) if there's no PHI, or a central database if there is PHI.
```

```r
# This last section is kinda cheating, and should belong in an 'analysis' file, not a 'manipulation' file.
#   It's included here for the sake of demonstration.

library(ggplot2)

# Graph each county-month
ggplot(ds, aes(x=month, y=fte, group=factor(county_id), color=factor(county_id), shape=fte_approximated, ymin=0)) +
  geom_point(position=position_jitter(height=.05, width=5), size=4, na.rm=T) +
  # geom_text(aes(label=county_month_id)) +
  geom_line(position=position_jitter(height=.1, width=5)) +
  scale_shape_manual(values=c("TRUE"=21, "FALSE"=NA)) +
  theme_light() +
  guides(color = guide_legend(ncol=4, override.aes = list(size=3, alpha = 1))) +
  guides(shape = guide_legend(ncol=2, override.aes = list(size=3, alpha = 1))) +
  labs(title="FTE sum each month (by county)", y="Sum of FTE for County")
```

<img src="stitched-output/manipulation/te/inspect-1.png" title="plot of chunk inspect" alt="plot of chunk inspect" style="display: block; margin: auto;" />

```r
# Graph each region-month
ds_region <- ds %>%
  dplyr::group_by(region_id, month) %>%
  dplyr::summarize(
    fte              = sum(fte, na.rm=T),
    fte_approximated = any(fte_approximated)
  ) %>%
  dplyr::ungroup()

last_plot() %+%
  ds_region +
  aes(group=factor(region_id), color=factor(region_id)) +
  labs(title="FTE sum each month (by region)", y="Sum of FTE for Region")
```

<img src="stitched-output/manipulation/te/inspect-2.png" title="plot of chunk inspect" alt="plot of chunk inspect" style="display: block; margin: auto;" />

```r
# last_plot() +
#   aes(y=fmla_hours) +
#   labs(title="fmla_hours sum each month (by county)")
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.4.1 (2017-06-30)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 16.04.3 LTS
## 
## Matrix products: default
## BLAS: /usr/lib/atlas-base/atlas/libblas.so.3.0
## LAPACK: /usr/lib/atlas-base/atlas/liblapack.so.3.0
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
## [1] ggplot2_2.2.1.9000 bindrcpp_0.2       DBI_0.7           
## [4] magrittr_1.5      
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.12          highr_0.6             compiler_3.4.1       
##  [4] plyr_1.8.4            bindr_0.1             tools_3.4.1          
##  [7] digest_0.6.12         bit_1.1-12            RSQLite_2.0          
## [10] evaluate_0.10.1       memoise_1.1.0         tibble_1.3.4         
## [13] checkmate_1.8.4       gtable_0.2.0          lattice_0.20-35      
## [16] pkgconfig_2.0.1       rlang_0.1.2.9000      yaml_2.1.14          
## [19] withr_2.0.0           dplyr_0.7.2           stringr_1.2.0        
## [22] knitr_1.17            hms_0.3               bit64_0.9-7          
## [25] grid_3.4.1            glue_1.1.1            OuhscMunge_0.1.8.9004
## [28] R6_2.2.2              tidyr_0.7.1           readr_1.1.1          
## [31] purrr_0.2.3           blob_1.1.0            backports_1.1.0      
## [34] scales_0.5.0          assertthat_0.2.0      testit_0.7           
## [37] colorspace_1.3-2      labeling_0.3          stringi_1.1.5        
## [40] lazyeval_0.2.0        munsell_0.4.3         markdown_0.8         
## [43] zoo_1.8-0
```

```r
Sys.time()
```

```
## [1] "2017-09-05 10:39:06 CDT"
```

