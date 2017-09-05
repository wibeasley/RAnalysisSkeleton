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

* Take small bites.  
    * Like all software development, don't tackle all the complexity the first time.  Start by processing only the important columns before incorporating move.
    * Use only the variables you need in the short-term, especially for new projects.  As everyone knows, the variables from the upstream source can change.  Don't spend effort writing code for variables you won't need for a few months/years; they'll likely change before you need them.
    * After a row passes through the `verify-values` chunk, you're accountable for any failures it causes in your warehouse.  All analysts know that external data is messy, so don't be surprised.  Sometimes I'll spend an hour writing an Ellis for 6 columns.

Elements
---------------------------------

1. **Clear memory**

    ```r
    rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
    ```
    
1. **Load Sources**

    ```r
    # ---- load-sources ------------------------------------------------------------
    ```

1. **Load Packages**
    ```r
    # ---- load-packages -----------------------------------------------------------
    library("magrittr")
    
    requireNamespace("readr"        )
    requireNamespace("tidyr"        )
    requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
    requireNamespace("testit")
    requireNamespace("checkmate")
    requireNamespace("OuhscMunge") #devtools::install_github(repo="OuhscBbmc/OuhscMunge")

    ```

1. **Declare Global Variables and Functions**.  In an Ellis, this include defining the expected column names and types of the data sources.
    ```r
    # ---- declare-globals ---------------------------------------------------------
    ```

1. **Load Data Source(s)** After this chunk, no new data should be introduced.
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

1. **Welcome** into your warehouse
    ```r
    # ---- upload-to-db ------------------------------------------------------------
    # ---- save-to-disk ------------------------------------------------------------
    ```

