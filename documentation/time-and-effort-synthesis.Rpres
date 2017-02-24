Time and Effort Dataset Synthesis
========================================================
autosize: true
OUHSC [Statistical Computing User Group](https://github.com/OuhscBbmc/StatisticalComputing)

Will Beasley, Dept of Pediatrics,

Biomedical and Behavioral Methodology Core ([BBMC](http://ouhsc.edu/BBMC/))

[2015-12-01](https://github.com/OuhscBbmc/StatisticalComputing/tree/master/2015_Presentations/12_December/)

Goal
========================================================
Combine three difference datasets that structurally and cosmetically differ.  The state data has three different sources, each managed by a different agency.

| File | Description |
| ---- | ----------- |
| [`nurse-month-oklahoma.csv`](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/nurse-month-oklahoma.csv) | one row per nurse per month for Oklahoma County |
| [`month-tulsa.csv`](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/month-tulsa.csv) | one row per month for Tulsa County (ie, it's already aggregated) |
| [`nurse-month-rural.csv`](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/nurse-month-rural.csv) | one row per nurse per month for the other 75 counties |

Structural Differences
========================================================
| | [Oklahoma](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/nurse-month-oklahoma.csv) | [Tulsa](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/month-tulsa.csv) | [Rural](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/nurse-month-rural.csv) | Approach |
| :----: | :----: | :----: | :----: | :----: |
| Structure | one row per month<br/> per nurse | one row per month<br/>(it's already aggregated) | one row per month<br/> per nurse | `dplyr`'s `group_by()`<br/>and `summarize()` |
| Contains PHI | Yes | n | Yes | Hash |
| Rename Fields | Yes | Yes | Yes | `dplyr::rename()` |
| Missing Values | n | n | Yes | compare county holes |
| Legit Holes | n | n | Yes | enumerate all combos<br/>and fill z/ zeros |
| Right Censored | Maybe | Maybe | n | group, sort, and<br/>`zoo::rollmedian()` |


Cosmetic Differences
========================================================
| | [Oklahoma](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/nurse-month-oklahoma.csv) | [Tulsa](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/month-tulsa.csv) | [Rural](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/data-public/raw/te/nurse-month-rural.csv) | Approach |
| :----: | :----: | :----: | :----: | :----: |
| Date | `Year` & `Month`<br/>separate | `1/15/2009` | `06/2012` | `as.Date()` `format`<br/>parameter |
| FTE Type | Proportion | Sum | Percentage | regex `gsub()` |
| Requires Linking Counties | Sorta | Sorta | Yes | Lookup Table<br/>& left join |
| Misspelled Counties | -- | -- | Yes | `car::recode()`<br/>or `plyr::revalue()` |
| Counties to Drop | n | n | Yes | blacklist |


Demo
========================================================
* [Code](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/manipulation/te-ellis.R)
* [Stitched Output](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/manipulation/stitched-output/te-ellis.md)

Stage 1 -Initial Stack
========================================================
[![Alt text](images/te-stage-1-county.png)](images/te-stage-1-county.png)
[![Alt text](images/te-stage-1-region.png)](images/te-stage-1-region.png)

Stage 2 -filled in missing records
========================================================
[![Alt text](images/te-stage-2-county.png)](images/te-stage-2-county.png)
[![Alt text](images/te-stage-2-region.png)](images/te-stage-2-region.png)

Stage 3 -interpolated missing months
========================================================
[![Alt text](images/te-stage-3-county.png)](images/te-stage-3-county.png)
[![Alt text](images/te-stage-3-region.png)](images/te-stage-3-region.png)

Stage 4 -extrapolated right censored
========================================================
[![Alt text](images/te-stage-4-county.png)](images/te-stage-4-county.png)
[![Alt text](images/te-stage-4-region.png)](images/te-stage-4-region.png)
