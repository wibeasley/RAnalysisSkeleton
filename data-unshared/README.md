`data-unshared/` Directory
=========

Files in this directory are stored on the local computer, but are not committed and are not sent to the central GitHub repository/server.  This makes the folder a decent container for:

1. **sensitive information**, such as [PHI](https://www.hhs.gov/answers/hipaa/what-is-phi/index.html) (Protected Health Information).  When PHI is involved, we recommend `data-unshared/` only if a database or a secured networked file share is not feasible.  See the discussion below.

1. **public files that are huge** (say, 1+ GB) and easily downloadable or reproducible.  For instance, files from stable sources like the US Census, NLSY, or Dataverse.

1. **diagnostic logs** that are not useful to collaborators.

A line in the repo's `.gitignore` file blocks the directory's contents from being staged/committed (look for `/data-unshared/*`).  Since files in this directory are not committed, it requires more discipline to communicate what files should be on a collaborator's computer.  Keep a list of files (like a table of contents) updated at `data-unshared/contents.md`; at a minimum declare the name of each file and how it can be downloaded or reproduced.  If you are curious the line `!data-unshared/contents.md` in `.gitignore` declares an exception so the markdown file is committed and updated on a collaborator's machine.

Even though these files are kept off the central repository, we recommend encrypting your local drive if the `data-unshared/` contains sensitive (such as PHI).  See the `data-public/` [`README.md`](data-public/) for more information.

The directory works best with the subdirectories described in the organization of [`data-public/`](../data-public/).

Compared to `data-unshared/`, we prefer storing PHI in an enterprise database (such as SQL Server, PostgreSQL, MariaDB/MySQL, or Oracle) or networked drive for four reasons.

1. These central resources are typically managed by Campus IT and reviewed by security professionals.
1. It's trivial to stay synchronized across collaborators with a file share or database. In contrast, `data-unshared/` isn't synchronized across machines so extra discipline is required to tell collaborators to update their machines.
1. It's sometimes possible to recover lost data from a file share or database.  It's much less likely to turn back the clock for `data-unshared/` files.
1. It's not too unlikely to mess up the `.gitignore` entries which would allow the sensitive files to be committed to the repository.  If sensitive information is stored on `data-unshared/`, it is important to review every commit to ensure information isn't about to sneak into the repo.
