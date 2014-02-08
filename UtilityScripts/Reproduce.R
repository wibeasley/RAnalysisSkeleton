
###################################
### Reproducible Research
###################################
# When executed by R, this file will manipulate the original data sources (ie, ZZZZ)
# to produce a groomed dataset suitable for analysis and graphing.

###################################
# Clear memory from previous runs
base::rm(list=base::ls(all=TRUE))

###################################
# Verify the working directory has been set correctly.  Much of the code assumes the working directory is the repository's root directory.
# In the following line, rename `RAnalysisSkeleton` to your repository.
if( base::basename(base::getwd()) != "RAnalysisSkeleton" ) {
  base::stop("The working directory should be set to the root of the package/repository.  ",
       "It's currently set to `", base::getwd(), "`.")
}
###################################
# Install the necessary packages.
pathInstallPackages <- "./UtilityScripts/InstallPackages.R"
if( !file.exists(pathInstallPackages)) {
  base::stop("The file `", pathInstallPackages, "` was not found.  Make sure the working directory is set to the root of the repository.")
}
base::source(pathInstallPackages) #TODO: launch in an encapsulated environment.

base::rm(pathInstallPackages)
###################################
# Load the necessary packages.
base::require(base)
base::require(knitr)
base::require(markdown)
base::require(testit)


#########################################################################################################
####
#### The following example comes from https://github.com/wibeasley/Wats.  Rename the paths appropriately.
####


# # Assert that the working directory has been set properly initial datasets can be found.  The 
# testit::assert("The 10 census files from 199x should exist.", base::file.exists(base::paste0("./Datasets/CensusIntercensal/STCH-icen199", 0:9, ".txt")))
# testit::assert("The 200x census file should exist.", base::file.exists("./Datasets/CensusIntercensal/CO-EST00INT-AGESEX-5YR.csv"))
# testit::assert("The county FIPS values should exist.", base::file.exists("./Datasets/CountyFipsCode.csv"))
# 
# # Execute code that restructures the Census data
# base::source("./UtilityScripts/IsolateCensusPopsForGfr.R")
# 
# # Assert that the intermediate files exist (the two produced by `IsolateCensusPopsForGfr.R`)
# testit::assert("The yearly records should exist.", base::file.exists("./Datasets/CensusIntercensal/CensusCountyYear.csv"))
# testit::assert("The monthly records should exist.", base::file.exists("./Datasets/CensusIntercensal/CensusCountyMonth.csv"))
# 
# #Execute code that combines the census and birth count data.
# base::source("./UtilityScripts/CalculateGfr.R")
# 
# # Verify that the two human readable datasets are present.
# testit::assert("The CSV for the 2005 Version should exist.", base::file.exists("./Datasets/CountyMonthBirthRate2005Version.csv"))
# testit::assert("The CSV for the 2014 Version should exist.", base::file.exists("./Datasets/CountyMonthBirthRate2014Version.csv"))
# 
# # Build the reports
# paths_report <- base::file.path("./vignettes", c("MbrFigures.Rmd", "OkFertilityWithIntercensalEstimates.Rmd"))
# for( path_rmd in paths_report ) {
#   path_md <- base::gsub(pattern=".Rmd$", replacement=".md", x=path_rmd)
#   path_html <- base::gsub(pattern=".Rmd$", replacement=".html", x=path_rmd)
#   knitr::knit(input=path_rmd, output=path_md)
#   markdown::markdownToHTML(file=path_md, output=path_html)
# }
