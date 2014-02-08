#This code checks the user's installed packages against the packages listed in `./UtilityScripts/PackageDependencyList.csv`.
#   These are necessary for the repository's R code to be fully operational. 
#   CRAN packages are installed only if they're not already; then they're updated if available.
#   GitHub packages are installed regardless if they're already installed.
#If anyone encounters a package that should be on there, please add it to `./UtilityScripts/PackageDependencyList.csv`

rm(list=ls(all=TRUE)) #Clear the memory of variables set during previous runs.
#####################################
## @knitr DeclareGlobals
pathCsv <- './UtilityScripts/PackageDependencyList.csv'

if( !file.exists(pathCsv)) stop("The path `", pathCsv, "` was not found.  Make sure the working directory is set to the root of the repository.")
#####################################
## @knitr LoadDatasets
dsPackages <- read.csv(file=pathCsv, stringsAsFactors=FALSE)

rm(pathCsv)
#####################################
## @knitr TweakDatasets
dsInstallFromCran <- dsPackages[dsPackages$Install & dsPackages$OnCran, ]
dsInstallFromGitHub <- dsPackages[dsPackages$Install & nchar(dsPackages$GitHubUsername)>0, ]

rm(dsPackages)
#####################################
## @knitr InstallDevtools
# Installing the devtools package is different than the rest of the packages.  On Windows,
#   the dll can't be overwritten while in use.  This function avoids that issue.

devtools::build_github_devtools() 
#####################################
## @knitr InstallCranPackages
for( packageName in dsInstallFromCran$PackageName ) {
  available <- require(packageName, character.only=TRUE) #Loads the packages, and indicates if it's available
  if( !available ) {
    install.packages(packageName, dependencies=TRUE)
    require( packageName, character.only=TRUE)
  }
}
rm(dsInstallFromCran, packageName, available)
#####################################
## @knitr UpdateCranPackages
update.packages(ask="graphics", checkBuilt=TRUE)

#####################################
## @knitr InstallGitHubPackages

for( i in seq_len(nrow(dsInstallFromGitHub)) ) {
  repositoryName <- dsInstallFromGitHub[i, "PackageName"]
  username <- dsInstallFromGitHub[i, "GitHubUsername"]
  devtools::install_github(repo=repositoryName, username=username)
}

rm(dsInstallFromGitHub, repositoryName, username)

#There will be a warning message for every  package that's called but not installed.  It will look like:
#    Warning message:
#        In library(package, lib.loc = lib.loc, character.only = TRUE, logical.return = TRUE,  :
#        there is no package called 'bootstrap'
#If you see the message (either in here or in another piece of the project's code),
#   then run this again to make sure everything is installed.  You shouldn't get a warning again.
