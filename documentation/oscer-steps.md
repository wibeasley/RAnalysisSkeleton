Steps to Clone & Run Repo in OU's Supercomputer
========

Almost no configuration is necessary because the computer already has R installed on schooner.

Hello World Example
---------------------------

This simple example is the bare minimum.

1. Perform the general supercomputer initialization
    1. Create user account: http://www.ou.edu/oscer/accounts_passwords
    1. Login to schooner.oscer.ou.edu: http://www.ou.edu/oscer/support/machine_access
    1. Find further account support info at: http://www.ou.edu/oscer/support/accounts/change_password

1. [Clone the repo](https://help.github.com/en/articles/cloning-a-repository) when SSH'd into schooner.  We'll use a simplified version that requires fewer package dependencies.

    ```bash
    git clone https://github.com/wibeasley/RAnalysisSkeleton.git
    git checkout scug-oscer
    cd RAnalysisSkeleton
    ```

    **The working directory must be set to `RAnalysisSkeleton`**.  If not, many steps below will fail.
    
    To access a private repo, or write to any repo, consider caching your personal access token:
    
        * https://help.github.com/en/articles/which-remote-url-should-i-use
        * https://help.github.com/en/articles/caching-your-github-password-in-git
        * https://github.com/settings/tokens

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
1. Three approaches to running all repo scripts with [`utility/super-computer/hello-world.R`](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/utility/super-computer/hello-world.R).

    1. Running interactively in R.  This is encouraged only for installing packages, and initially testing small projects like this.
        ```r
        source("utility/super-computer/hello-world.R")
        ```

    1. Running interactively with Rscript in the bash shell.  This is encouraged only for initially testing small projects like this.

        ```r
        Rscript utility/super-computer/hello-world.R > utility/super-computer/output.txt
        ```

    1. Run with a batch file. See also http://www.ou.edu/oscer/support/running_jobs_schooner
        --Henry, work your magic here.

        Live batch file: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/utility/super-computer/r-batch.sh

        1. Make sure the working directory is `RAnalysisSkeleton` with `pwd`.
        1. Modify the batch file with `nano utility/super-computer/r-batch.sh` at least
            * email address
            * working directory
        1. Submit the batch file with `sbatch utility/super-computer/r-batch-hello.sh`.  (Hint, use the keyboard's up arrow.)

Multiple File Example
---------------------------

More realistic scenarios require (a) installing R packages and sometimes Linux packages and (b) coordinating multiple R files
and multiple data files.  

1. Install a single R package.  Install the [remotes](https://CRAN.R-project.org/package=remotes) package.  We'll do this in R (instead of bash), because it more easily establishes a local personal library.

    Install package in R.  A lot needs to be compiled, so this takes a few minutes.
    ```R
    install.packages("remotes")
    ```

    When prompted, respond
    * `y` to 'Would you like to use a personal library instead? (yes/No/cancel)'
    * `y` to 'Would you like to create a personal library ~/R/x86_64-redhat-linux-gnu-library/3.5 to install packages into? (yes/No/cancel)'
    * `1` to select the '0-Cloud [https]' CRAN mirror

1. Install a list of roughly 50 packages from [utility/package-dependency-list.csv](https://github.com/wibeasley/RAnalysisSkeleton/blob/master/utility/package-dependency-list.csv) in R.  Their 100+ (package) dependencies are also installed, which takes 120+ minutes.

    ```r
    # These packages are included in the list, but we want to avoid their 'Suggests' dependencies.
    install.packages(c("dplyr"), dependencies=NA)
    
    remotes::install_github("OuhscBbmc/OuhscMunge", ref = "dev")
    OuhscMunge::package_janitor_remote(
      "utility/package-dependency-list.csv",
      dependencies = NA                               # Avoid the 'Suggests' packages
    )
    ```

    For machines that we have full admin rights, the previous two blocks are replaced with `source("utility/install-packages.R")`.  But this approach installs [a longer list of R packages](https://github.com/OuhscBbmc/RedcapExamplesAndPatterns/blob/master/utility/package-dependency-list.csv), which likely requires additional Linux packages.  If you need additional Linux packages installed, contact [OSCER support](http://www.ou.edu/oscer) at support@oscer.ou.edu.

1. Run "utility/reproduce.R" similarly as the Hello Word example above.
    * For the html reports, pandoc should be loaded in the batch file with `module load Pandoc/2.5`.

Next Steps & General Advice
---------------------------

1. Develop new code on your local machine, and transfer it to schooner.  We recommend GitHub for several reasons.  Updated code can be pulled into schooner with the bash command `git pull` (from the repo's root directory).

1. Start small.  Gradually increase complexity.

1. Managing lodes of code & output
    1. breaking up a large problem into several semi-independent components
    1. keeping track of different output versions, and their corresponding upstream code.  (Referencing the git commit might help a little.)

1. Use WinSCP for transferring output and other files that fall outside of the git repo.  See http://www.ou.edu/oscer/support/file_transfer#windows_winscp.

1. Tradeoffs between different types of OSCER file storage.

1. Installing R packages on Linux is more fragile than on Windows, because all the package's source code must be compiled.  Also, some of the R packages depend on Linux packages; [sometimes the installation error messages](https://stackoverflow.com/a/49165163/1082435) are good.  Consider consulting OSCER support if you can't get an R package to install within the first few tries.
