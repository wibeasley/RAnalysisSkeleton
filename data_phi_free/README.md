`./DataPhiFree/` Directory
=========

This directory should contain that DO NOT hold PHI, or any other sensitive information.  Files with PHI should **not** be stored in a GitHub repository, even a private GitHub repository.  We recommend using an enterprise database (such as MySQL or SQL Server) to store the data, and read & write the information to/from the software right before and after it's used.  

If a database isn't feasible, consider storing the files in `./DataUnshared/`, whose contents are not committed to the repository; a line in `./.gitignore/` keeps the files uncommitted/unstaged.  However, there could be some information that is sensitive enough that it shouldn't even be stored locally without encryption (such as PHI).
