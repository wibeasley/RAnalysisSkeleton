`./data-public/raw/` Directory
=========

This directory should contain the raw, unmodified files that serve as an input to the project.  In theory the schema of these data files shouldn't change when new data arrive.  But of course this is frequenlty violated, so at minimum, our code should assert that the required columns are present, and contain reasonable values.  More thorough checking can be warranted.

For the sake of long-term reproducibility, these files are ideally in a nonproprietary format that is human readable.  Plain text files (eg, CSVs & XML) are preferred. Binary & proprietary formats (eg, Excel & SAS) may not be readable if certain softrware is missing fro mthe user's computer; or they might be able to be read by only old versions of software (eg, Excel 97).

## No PHI
Files with PHI should **not** be stored in a GitHub repository, even a private GitHub repository.  We recommend using an enterprise database (such as MySQL or SQL Server) to store the data, and read & write the information to/from the software right before and after it's used. If a database isn't feasible, consider storing the files in `./data-unshared/`, whose contents are not committed to the repository; a line in `./.gitignore/` keeps the files uncommitted/unstaged.  However, there could be some information that is sensitive enough that it shouldn't even be stored locally without encryption (such as PHI).
