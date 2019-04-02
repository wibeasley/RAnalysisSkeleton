# dir.create("stitched-output/utility")

knitr::stitch_rmd(
  script = "utility/reproduce.R", 
  output = "stitched-output/utility/reproduce.md"
)
