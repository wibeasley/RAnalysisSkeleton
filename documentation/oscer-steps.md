Steps to Clone & Run Repo in OU's Supercomputer
========

Almost no configuration is necessary because the computer already has R installed on schooner. 

1. Clone repo to local machine.

    ```bash
    git clone https://github.com/wibeasley/RAnalysisSkeleton.git
    cd RAnalysisSkeleton
    ```

1. Install a single package.  Open R and install the [devtools](https://CRAN.R-project.org/package=devtools) package.  We'll do this in R (instead of bash), because it more easily establishes a local personal library.

    Open R with bash.
    ```bash
    R
    ```
    
    Install package in R.  A lot needs to be compiled, so this take ~4 minutes
    ```R
    install.packages("devtools")
    ```
    
    When prompted, respond
    * `y` to 'Would you like to use a personal library instead? (y/n)'
    * `y` to 'Would you like to create a personal library ~/R/x86_64-redhat-linux-gnu-library/3.3'
    * `1` to select the '0-Cloud [https]' CRAN mirror

1. Install a list of 50ish packages from [utility/package-dependency-list.csv](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/utility/package-dependency-list.csv) in R.  Their (package) dependencies are also installed, which takes 15 minutes.
    
    ```R
    source("utility/install-packages.R")
    ```
