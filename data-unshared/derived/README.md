`./data-unshared/derived` Directory
=========
In this directory, save the 'derived' files that are produced from the manipulation code we write, especially if multiple reports use these variables.  Having a common cleaned dataset reduces duplication, which improves robustness.  Unless there's a good reason to avoid binary (ie, non-text) formats, save as `*.rds` with the `xz` compression.   The RDS format maintains the `data.frame` metadata such as dates and factor levels (which the CSV format loses).  The compression saves disk space (which also reduces load time).

Files in this directory are stored locally, but not staged/committed and sent to the central GitHub repository.  For more information, see `./data-unshared/README.md`
