`stitched-output/` Directory
=========

In this directory, include content that helps describe the automated and reproducible flow.  We prefer to generate this output with [`knitr::stitch()`](https://yihui.name/knitr/demo/stitch/).  These content doesn't need to be pretty for external consumption.  But it should clearly describe the state of the process at this moment in time.  [Comparing diffs](https://help.github.com/articles/comparing-commits-across-time/) of these files should help reveal if something major has changed between runs.

This directory's internal structure should mimic the repo directory structure.  For example, the file `manipulation/te-ellis.R` should produce `stitched-output/manipulation/te-ellis.md`.
