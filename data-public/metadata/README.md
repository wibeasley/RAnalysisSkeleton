`./data-public/metadata/` Directory
=========

This directory should contain only data files that describe structure of the project or other datasets.  For example, specifying that `1` and `2` represents 'male' and 'female'.

Ideally datasets are stored as CSVs, so they are easily portable, accessible, and modifiable from any software.

## No PHI
Files with PHI should **not** be stored in a GitHub repository, even a private GitHub repository.  We recommend using an enterprise database (such as MySQL or SQL Server) to store the data, and read & write the information to/from the software right before and after it's used.  If a database isn't feasible, consider storing the files in [`./data-unshared/`](./data-unshared/), whose contents are not committed to the repository; a line in [`./.gitignore/`](./.gitignore/) keeps the files uncommitted/unstaged.  However, there could be some information that is sensitive enough that it shouldn't even be stored locally without encryption (such as PHI).
