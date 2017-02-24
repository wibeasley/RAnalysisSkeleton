`./data-unshared/` Directory
=========
Files in this directory are stored locally, but not staged/committed and sent to the central GitHub repository.  A line in `./.gitignore/` keeps the files uncommitted/unstaged.

Even though these files are kept off the central repository, it still should not contain anything sensitive enough that it requires encryption when stored on your local drive (such as PHI).  See the `data-public/` [`README.md`](data-public/) for more information.

Since files in this directory are not staged/committed, it's tough to communicate with collaborators what the files should look like on their computers.  Try to keep a list updated at `./data-unshared/contents.md`
