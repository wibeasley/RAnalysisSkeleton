`data-public/` Directory
=========

This directory should contain information that is not sensitive and is not proprietary.  It SHOULD NOT hold [PHI](https://www.hhs.gov/answers/hipaa/what-is-phi/index.html) (Protected Health Information), or other information like participant names, social security numbers, or passwords.  Files with PHI should **not** be stored in a GitHub repository, even a [private GitHub repository](https://help.github.com/articles/publicizing-or-hiding-your-private-contributions-on-your-profile/).

Please see [`data-unshared/`](../data-unshared/) for options storing sensitive information.

The `data-public/` directory typically works best if organized with subdirectories.  We commonly use

* **`data-public/raw/`** for the input to the pipelines.  These datasets usually represents all the hard work of the data collection.

* **`data-public/metadata/`** for the definitions of the datasets in raw.  For example, "gender.csv" might translate the values 1 and 2 to male and female.  Sometimes a dataset feels natural in either the raw or the metadata subdirectory.  If the file would remain unchanged if a subsequent sample was collected, lean towards metadata.

* **`data-public/derived/`** for output of the pipelines.  Its contents should be completely reproducible when starting with `data-public/raw/` and the repo's code.  In other words, it can be deleted and recreated at ease.  This might contain a small database file, like SQLite.

* **`data-public/logs/`** for logs that are useful to collaborators or necessary to demonstrate something in the future, beyond the reports contained in the `analysis/` directory.

* **`data-public/original/`** for nothing (hopefully); ideally it is never used.  It is similar to `data-public/raw/`.  The difference is that `data-public/raw/` is called by the pipeline code, while `data-public/original/`  is not.

  A file in `data-public/original/`typically comes from the investigator in a malformed state and requires some manual intervention; then it is copied to `data-public/raw/`.  Common offenders are (a) a csv or Excel file with bad or missing column headers, (b) a strange file format that is not readable by an R package, (c) a corrupted file that require a rehabilitation utility.

The characteristics of `data-public/` vary based on the subject matter.  For instance, medical research projects typically use only the metadata directory, because the incoming information contains PHI and is stored in a database.  On the other hand, microbiology and physics research typically do not have data protected by law, and it is desirable for the repo to contain everything.

We feel a private GitHub repo offers adequate protection if being scooped is the biggest risk.
