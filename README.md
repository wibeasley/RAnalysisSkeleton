R Analysis Skeleton
=====================

> [No one beginning a data science project should start from a blinking cursor.](https://towardsdatascience.com/better-collaborative-data-science-d2006b9c0d39) <br/>...Templatization is a best practice for things like using common directory structure across projects...<br/>
> -[Megan Risdal](https://towardsdatascience.com/@meganrisdal) Kaggle Product Lead.

This project contains the files and settings commonly used in analysis projects with R.  A developer can start an analysis repository more quickly by copying these files.  The purpose of each directory is described in its README file.  Some aspects are more thoroughly described in [Collaborative Data Science Practices](https://ouhscbbmc.github.io/data-science-practices-1/).

Pipelines
=====================

The repo contains two pipelines that aim to be simple enough to understand, yet complex enough to mimic aspects frequently seen in analysis projects.

Cars
--------------------------

The simplest example involves a csv that is lightly groomed and saved as an [rds]() file.  A knitr Rmd file analyzes the rds; the text, graphs, and tables are saved as a self-contained html.  The html file is very portable; it can be saved on a drive, emailed to a colleague, or publicly served on a website.

<img src="documentation/images/flow-skeleton-car.png" alt="flow-skeleton-car" height="187" >

Intra-individual Differences
--------------------------

 Most nontrivial data science projects require multiple sources to address a single issue.  This example uses three sources: (a) longitudinal measurements for individuals across time (`mlm.csv`), (b) static county characteristics (`county.csv`), and (c) longintudinal county-level characteristics (`te.csv`).  Each csv is independently groomed and loaded into its own database table (in `db.sqlite`) by an **ellis lane**.  Conventional statistical software is not designed to digest multiple data rectangles; a **scribe** transforms multple   [database-normalized](https://www.essentialsql.com/get-ready-to-learn-sql-database-normalization-explained-in-simple-english/) tables into a single rds that can be analyzed directly.  In this case, the `mlm.rds` supports two analyses: a conventional **report** of statistical inferences intended for subject-experts concerned with complex hypotheses, and a **dashboard** of simplified patterns intended for administrators concerned with operational progress.  The `te.rds` supports a comparison of the *t*ime and *e*ffort results between counties.

<img src="documentation/images/flow-skeleton.png" alt="flow-skeleton" height="399" >

Establishing a Workstation for Analysis
=====================

1. Install and configure the needed software, as described in the [Workstation](https://ouhscbbmc.github.io/data-science-practices-1/workstation.html) chapter of [*Collaborative Data Science Practices*](https://ouhscbbmc.github.io/data-science-practices-1/).  Select the programs to meet your needs, and if in doubt, cover the Required Installation section and then pick other tools as necessary.

1. Download the repo to your local machine.  One option is to [clone](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository) it.
   
1. On your local machine, open the project in [RStudio](https://rstudio.com/products/rstudio/) by double-clicking [RAnalysisSkeleton.Rproj](RAnalysisSkeleton.Rproj).

1. Install the packages needed for this repo.  Within the RStudio console, execute these two lines.  The first line installs a package.  The second line inspects the repo's [DESCRIPTION](DESCRIPTION) file to identify and install the prerequisites.
   
    ```r
    remotes::install_github(repo="OuhscBbmc/OuhscMunge")
    OuhscMunge::update_packages_addin()
    ```

1. Execute the entire pipeline of the repo by executing the [flow.R](flow.R) file.  Open it in RSutdio and click the 'Source' button near the top right of the screen.  The flow file then tells other files to run in the desired order.  Running this file creates the data objects --*i.e.*, the primary objective of this repo.  The objects include (a) intermediate data files, (b) analysis-ready datafiles, and (c) html reports that display the ultimate analyses.
   
1. If you'd like to view the database created by this repo's pipeline, install a program that can visually explore a [SQLite](https://www.sqlite.org/) file.  Two of many options are [SQLiteStudio](https://sqlitestudio.pl/) and [DB Browser for SQLite](https://sqlitebrowser.org/).
