# dir.create("stitched-output")

knitr::stitch_rmd(
  script = "flow.R",
  output = "stitched-output/flow.md"
)
