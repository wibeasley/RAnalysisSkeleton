# knitr::stitch_rmd(script="./utility/reproduce.R", output="./utility/reproduce.md")

# Reproducible Research ---------------------------------------------------
#' When executed by R, this file will manipulate the original data sources (ie, ZZZZ)
#' to produce a groomed dataset suitable for analysis and graphing.

# Clear memory from previous runs -----------------------------------------
base::rm(list=base::ls(all=TRUE))

# Check Working Directory -------------------------------------------------
#' Verify the working directory has been set correctly.  Much of the code assumes the working directory is the repository's root directory.
#' In the following line, rename `RAnalysisSkeleton` to your repository.
if( base::basename(base::getwd()) != "RAnalysisSkeleton" ) {
  base::stop("The working directory should be set to the root of the package/repository.  ",
       "It's currently set to `", base::getwd(), "`.")
}

# Install the necessary packages ------------------------------------------
path_install_packages <- "./utility/install-packages.R"
if( !file.exists(path_install_packages)) {
  base::stop("The file `", path_install_packages, "` was not found.  Make sure the working directory is set to the root of the repository.")
}
base::source(path_install_packages, local=new.env())

base::rm(path_install_packages)

# Load the necessary packages ---------------------------------------------
base::requireNamespace("base", quietly=T)
base::requireNamespace("knitr", quietly=T)
base::requireNamespace("markdown", quietly=T)
base::requireNamespace("testit", quietly=T)

######################################################################################################
#' The following example comes from https://github.com/wibeasley/Wats.  Rename the paths appropriately.

# Declare the paths of the necessary files --------------------------------

#' The raw/input data files:
# pathCensus199x <- base::paste0("./Datasets/CensusIntercensal/STCH-icen199", 0:9, ".txt")
# pathCensus200x <- "./Datasets/CensusIntercensal/CO-EST00INT-AGESEX-5YR.csv"
# pathCountyFips <- "./Datasets/CountyFipsCode.csv"

#' The derived/intermediate data files (which are produced by the repository's code files):
# pathCensusYearly <- "./Datasets/CensusIntercensal/CensusCountyYear.csv"
# pathCensusMonthly <- "./Datasets/CensusIntercensal/CensusCountyMonth.csv"
# pathDataForAnalaysis2005 <- "./Datasets/CountyMonthBirthRate2005Version.csv"
# pathDataForAnalaysis2014 <- "./Datasets/CountyMonthBirthRate2014Version.csv"

#' Code Files:
# pathManipulateCensus <- "./UtilityScripts/IsolateCensusPopsForGfr.R"
# pathCalculateGfr <- "./UtilityScripts/CalculateGfr.R"

#' Report Files:
# pathsReports <- base::file.path("./vignettes", c("MbrFigures.Rmd", "OkFertilityWithIntercensalEstimates.Rmd"))

# Verify the necessary path can be found ----------------------------------

#' The raw/input data files:
# testit::assert("The 10 census files from 199x should exist.", base::file.exists(pathCensus199x))
# testit::assert("The 200x census file should exist.", base::file.exists(pathCensus200x))
# testit::assert("The county FIPS values should exist.", base::file.exists(pathCountyFips))

#' Code Files:
# testit::assert("The file that restructures the census data should exist.", base::file.exists(pathManipulateCensus))
# testit::assert("The file that calculates the GFR should exist.", base::file.exists(pathCalculateGfr))

# Report Files:
# testit::assert("The knitr Rmd files should exist.", base::file.exists(pathsReports))

# Run the files that manipulate and analyze -------------------------------

#' Execute code that restructures the Census data
# base::source(pathManipulateCensus, local=base::new.env())

#' Assert that the intermediate files exist (the two files produced by `IsolateCensusPopsForGfr.R`)
# testit::assert("The yearly records should exist.", base::file.exists(pathCensusYearly))
# testit::assert("The monthly records should exist.", base::file.exists(pathCensusMonthly))

#' Execute code that combines the census and birth count data.
# base::source(pathCalculateGfr, local=base::new.env())

#' Verify that the two human readable datasets are present.
# testit::assert("The CSV for the 2005 Version should exist.", base::file.exists(pathDataForAnalaysis2005))
# testit::assert("The CSV for the 2014 Version should exist.", base::file.exists(pathDataForAnalaysis2014))

# Build the reports -------------------------------------------------------
# for( pathRmd in pathsReports ) {
#   pathMd <- base::gsub(pattern=".Rmd$", replacement=".md", x=pathRmd)
#   pathHtml <- base::gsub(pattern=".Rmd$", replacement=".html", x=pathRmd)
#   knitr::knit(input=pathRmd, output=pathMd)
#   markdown::markdownToHTML(file=pathMd, output=pathHtml)
# }
