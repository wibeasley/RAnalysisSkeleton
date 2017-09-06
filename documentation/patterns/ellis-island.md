Ellis Island Pattern
=================================

Purpose
---------------------------------
To incorporate outside data source into your system safely.

Philosophy
---------------------------------
* Without data immigration, all warehouses are useless.  Embrace the power of fresh information in a way that is:
    * repeatable when the datasource is updated (and you have to refresh your warehouse)
    * similar to other Ellis lanes (that are designed for other data sources) so you don't have to learn/remember an entirely new pattern. (Like Rubiks cube instructions.)

Guidelines
---------------------------------
* Take small bites.  
    * Like all software development, don't tackle all the complexity the first time.  Start by processing only the important columns before incorporating move.
    * Use only the variables you need in the short-term, especially for new projects.  As everyone knows, the variables from the upstream source can change.  Don't spend effort writing code for variables you won't need for a few months/years; they'll likely change before you need them.
    * After a row passes through the `verify-values` chunk, you're accountable for any failures it causes in your warehouse.  All analysts know that external data is messy, so don't be surprised.  Sometimes I'll spend an hour writing an Ellis for 6 columns.
    
* Narrowly define each Ellis lane.  One code file should strive to (a) consume only one CSV and (b) produce only one table.  Exceptions include: 
    1. if multiple input files are related, and really belong together (*e.g.*, one CSV per month, or one CSV per clinic).  This scenario is pretty common.
    1. if the CSV should legitimately produce two different tables after munging.  This happens infrequently, such as one warehouse table needs to be wide, and another long.
    

Examples
---------------------------------    
* https://github.com/wibeasley/RAnalysisSkeleton/blob/master/manipulation/te-ellis.R
* https://github.com/wibeasley/RAnalysisSkeleton/blob/master/manipulation/
* https://github.com/OuhscBbmc/usnavy-billets/blob/master/manipulation/survey-ellis.R

Elements
---------------------------------

1. **Clear memory** In scripting languages like R (unlike compiled languages like Java), it's easy for old variables to hang around.  Explicitly clear them before you run the file again.

    ```r
    rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
    ```
    
1. **Load Sources** In R, a `source()`d file is run to execute its code.  We prefer that a sourced file only load variables (like function definitions), instead of do real operations like read a dataset or perform a calculation.  There are many times that you want a function to be available to multiple files in a repo; there are two approaches we like.  The first is collecting those common functions into a single file (and then sourcing it in the callers).  The second is to make the repo a legitimate R package.

    The first approach is better suited for quick & easy development.  The second allows you to add documention and unit tests.

    ```r
    # ---- load-sources ------------------------------------------------------------
    source("./manipulation/osdh/ellis/common-ellis.R")
    ```

1. **Load Packages** This is another precaution necessary in a scripting language.  Determine if the necessary packages are available on the machine.  Avoiding attaching packages (with the `library()` function) when possible.  Their functions don't need to be qualified (*e.g.*, `dplyr::intersect()`) and could cause naming conflicts.  Even if you can guarantee they don't conflict with packages now, packages could add new functions in the future that do conflict.


    ```r
    # ---- load-packages -----------------------------------------------------------
    # Attach these package(s) so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
    library(magrittr            , quietly=TRUE)
    library(DBI                 , quietly=TRUE)
    
    # Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
    requireNamespace("readr"        )
    requireNamespace("tidyr"        )
    requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
    requireNamespace("testit")
    requireNamespace("checkmate")
    requireNamespace("OuhscMunge") #devtools::install_github(repo="OuhscBbmc/OuhscMunge")

    ```

1. **Declare Global Variables and Functions**.  This includes defining the expected column names and types of the data sources; use `readr::cols_only()` (as opposed to `readr::cols()`) to ignore any new columns that may be been added since the dataset's last refresh.

    ```r
    # ---- declare-globals ---------------------------------------------------------
    ```

1. **Load Data Source(s)** Read all data (*e.g.*, database table, networked CSV, local lookup table).  After this chunk, no new data should be introduced.  This is for the sake of reducing human cognition load.  Everything below this chunk is derived from these first four chunks.

    ```r
    # ---- load-data ---------------------------------------------------------------
    ```

1. **Tweak Data**
    ```r
    # ---- tweak-data --------------------------------------------------------------
    ```


1. **Body of the Ellis**

1. **Verify**
    ```r
    # ---- verify-values -----------------------------------------------------------
    county_month_combo   <- paste(ds$county_id, ds$month)
    checkmate::assert_character(county_month_combo, pattern  ="^\\d{1,2} \\d{4}-\\d{2}-\\d{2}$", any.missing=F, unique=T)
    ```

1. **Specify Columns** Define the exact columns and order to upload to the database.  Once you import a column into a warehouse that multiple people are using, it's tough to remove it.
    ```r
    # ---- specify-columns-to-upload -----------------------------------------------
    ```

1. **Welcome** into your warehouse.  Until this chunk, nothing should be persisted.
    ```r
    # ---- upload-to-db ------------------------------------------------------------
    # ---- save-to-disk ------------------------------------------------------------
    ```
