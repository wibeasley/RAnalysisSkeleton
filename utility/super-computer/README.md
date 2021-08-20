`utility/super-computer/` Directory
=========

The files in this directory support the April 2019 [SCUG](https://github.com/OuhscBbmc/StatisticalComputing) presentation.

1. There are two files involved in a conventional operation.
    1. The R file that performs the data manipulation & analysis.
    1. The batch file that calls the R file and specific parameters specific to the super computer.

1. To run
    1. SSH into schooner
    1. Set the working directory with `cd RAnalysisSkeleton`.
    1. Modify the batch file with `nano utility/super-computer/r-batch-hello.sh` (or `r-batch-repo.sh`). 
        * email address
        * working directory
        * If you're in Windows, you may need to change the line endings in the sh file.  For example, in the lower right corner of VS Code, change "CRLF" to "LF".
    1. Submit the batch file with `sbatch utility/super-computer/r-batch-hello.sh` (or `r-batch-repo.sh`).  (Hint, use the keyboard's up arrow.)
    1. Check the status of your submitted jobs with `squeue -u username` (where `username` is your oscer username like 'skerr')

1. This R file and shell file corresponds closely with OSCER's advice at http://ou.edu/oscer/support/R_package. The differences involve
    1. file naming.
        * The R file is called `hello-world.R`, instead of `helloworld.r`.
        * The batch shell file is called `r-batch-hello.R`, instead of `r_batch.sh`.
        * Both files are nested in the `utility/super-computer` directory (the root directory).
    1. a newer & explicit version of R.
        * The batch file specifies `module load R/4.0.2-foss-2020a` instead of just `module load R`.
