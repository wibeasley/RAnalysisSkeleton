Steps to Clone & Run Repo in OU's Supercomputer
========

Almost no configuration is necessary because the computer already has R installed on schooner. 

1. Perform the general supercomputer initialization
    1. Create user account: http://www.ou.edu/oscer/accounts_passwords
    1. Login to schooner.oscer.ou.edu: http://www.ou.edu/oscer/support/machine_access
    1. Find further account support info at: http://www.ou.edu/oscer/support/accounts/change_password

1. [Clone the repo](https://help.github.com/en/articles/cloning-a-repository) when SSH'd into schooner.

    ```bash
    git clone https://github.com/wibeasley/RAnalysisSkeleton.git
    cd RAnalysisSkeleton
    ```

1. Check that you can open the desired version of R.  As of March 2019, there are five versions installed on schooner (ranging from 3.3.2 to 3.5.1).  OSCER's R-specific documentation is http://ou.edu/oscer/support/R_package.  (Thanks to Horst Severini.)

    View the possible R versions with the bash command:
    
    ```bash
    module avail R/
    ```
    
    Set your *session’s* default version to 3.5.1 in bash.  This command will need to be repeated for each SSH/terminal session and batch file.  (Batch files are covered below.)
    ```bash
    module load R/3.5.1-intel-2016a
    ```
    
    Open R with bash.  Make sure the version is correct (*e.g.*, 3.5.1 if you used the command above).
    ```bash
    R
    ```
    
1. Install a single package.  Install the [remotes](https://CRAN.R-project.org/package=remotes) package.  We'll do this in R (instead of bash), because it more easily establishes a local personal library.
 
    Install package in R.  A lot needs to be compiled, so this take ~4 minutes.
    ```R
    install.packages("remotes")
    ```
    
    When prompted, respond
    * `y` to 'Would you like to use a personal library instead? (yes/No/cancel)'
    * `y` to 'Would you like to create a personal library ~/R/x86_64-redhat-linux-gnu-library/3.5 to install packages into? (yes/No/cancel)'
    * `1` to select the '0-Cloud [https]' CRAN mirror

1. Install a list of roughly 50 packages from [utility/package-dependency-list.csv](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/utility/package-dependency-list.csv) in R.  Their 100+ (package) dependencies are also installed, which takes 60+ minutes.

    ```r
    remotes::install_github("OuhscBbmc/OuhscMunge", ref = "dev")
    OuhscMunge::package_janitor_remote("utility/package-dependency-list.csv")
    ```
    
    For machines that we have full admin rights, the previous two blocks are replaced with `source("utility/install-packages.R")`.  But this approach installs [a longer list of R packages](https://github.com/OuhscBbmc/RedcapExamplesAndPatterns/blob/master/utility/package-dependency-list.csv), which likely requires additional linux packages.  If you need additional Linux packages installed, contact [OSCER support](http://www.ou.edu/oscer) at support@oscer.ou.edu.
    
1. Three approaches to running all repo scripts with [`utility/reproduce.R`](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/utility/reproduce.R).

    1. Running interactively in R.  This is encouraged only for installing packages, and initially testing small projects like this.
        ```r
        source("utility/reproduce.R")
        ```
       
    
    1. Running interactively with Rscript in the bash shell.  This is encouraged only for initially testing small projects like this.
        ```bash
        Rscript utility/reproduce.R  # This is untested
        ```
        
        A super simple example is
        ```r
        Rscript utility/super-computer/hello-world.R > utility/super-computer/output.txt
        ```
    
    1. Run with a batch/bsub file. See also http://www.ou.edu/oscer/support/running_jobs_schooner
        --Henry, work your magic here.

Next Steps & General Advice
========

1. Develop new code on your local machine, and transfer it to schooner.  We recommend GitHub for several reasons.  Updated code can be pulled into schooner with the bash command `git pull` (from the repo's root directory).

1. Start small & build in complexity.
    1. Code
    1. Cores & Memory

1. Managing lodes of code & output
    1. breaking up a large problem into several semi-independent components
    1. keeping track of different output versions, and their corresponding upstream code.  (Referencing the git commit might help a little.)

1. Use WinSCP for transferring output and other files that fall outside of the git repo.  See http://www.ou.edu/oscer/support/file_transfer#windows_winscp.

1. Tradeoffs between different types of OSCER file storage.
