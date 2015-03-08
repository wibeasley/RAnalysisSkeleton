#This code checks the user's installed packages against the packages listed in `./UtilityScripts/PackageDependencyList.csv`.
#   These are necessary for the repository's R code to be fully operational. 
#   CRAN packages are installed only if they're not already; then they're updated if available.
#   GitHub packages are installed regardless if they're already installed.
#If anyone encounters a package that should be on there, please add it to `./UtilityScripts/PackageDependencyList.csv`

#Clear memory from previous runs,.
base::rm(list=base::ls(all=TRUE))

#####################################
## @knitr DeclareGlobals
pathCsv <- './UtilityScripts/PackageDependencyList.csv'

if( !file.exists(pathCsv)) 
  base::stop("The path `", pathCsv, "` was not found.  Make sure the working directory is set to the root of the repository.")
#####################################
## @knitr LoadDatasets
dsPackages <- utils::read.csv(file=pathCsv, stringsAsFactors=FALSE)

rm(pathCsv)
#####################################
## @knitr TweakDatasets
dsInstallFromCran <- dsPackages[dsPackages$Install & dsPackages$OnCran, ]
dsInstallFromGitHub <- dsPackages[dsPackages$Install & !is.na(dsPackages$GitHubUsername) & nchar(dsPackages$GitHubUsername)>0, ]

rm(dsPackages)
#####################################
## @knitr InstallCranPackages
for( packageName in dsInstallFromCran$PackageName ) {
  available <- base::require(packageName, character.only=TRUE) #Loads the packages, and indicates if it's available
  if( !available ) {
    utils::install.packages(packageName, dependencies=TRUE)
    base::require( packageName, character.only=TRUE)
  }
  base::rm(available)
}
rm(dsInstallFromCran, packageName)
#####################################
## @knitr CheckForLibCurl

if( R.Version()$os=="linux-gnu" ) {
  libcurl_results <- base::system("locate libcurl4")
  libcurl_missing <- (libcurl_results==0)
  
  if( libcurl_missing )
    base::warning("This Linux machine is possibly missing the 'libcurl' library.  ",
            "Consider running `sudo apt-get install libcurl4-openssl-dev`.")
  
  base::rm(libcurl_results, libcurl_missing)
}


#####################################
## @knitr UpdateCranPackages
utils::update.packages(ask=FALSE, checkBuilt=TRUE)

#####################################
## @knitr InstallDevtools
# Installing the devtools package is different than the rest of the packages.  On Windows,
#   the dll can't be overwritten while in use.  This function avoids that issue.
# This should follow the initial CRAN installation of `devtools`.  
#   Installing the newest GitHub devtools version isn't always necessary, but it usually helps.

downloadLocation <- "./devtools.zip" #This is the default value.
devtools::build_github_devtools(downloadLocation) 

base::unlink(downloadLocation, recursive=FALSE) #Remove the file from disk.
base::rm(downloadLocation)
#####################################
## @knitr InstallGitHubPackages

for( i in base::seq_len(base::nrow(dsInstallFromGitHub)) ) {
  package_name <- dsInstallFromGitHub[i, "PackageName"]
  username <- dsInstallFromGitHub[i, "GitHubUsername"]
  repository_name <- paste0(username, "/", package_name)
  devtools::install_github(repo=repository_name)
  base::rm(package_name, username, repository_name)
}

base::rm(dsInstallFromGitHub, i)

#There will be a warning message for every  package that's called but not installed.  It will look like:
#    Warning message:
#        In library(package, lib.loc = lib.loc, character.only = TRUE, logical.return = TRUE,  :
#        there is no package called 'bootstrap'
#If you see the message (either in here or in another piece of the project's code),
#   then run this again to make sure everything is installed.  You shouldn't get a warning again.
