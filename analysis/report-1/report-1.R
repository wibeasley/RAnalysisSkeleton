rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# @knitr load_sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("./SomethingSomething.R")

# @knitr load_packages -----------------------------------------------------------
library(ggplot2) #For graphing
# library(magrittr) #Pipes
requireNamespace("knitr", quietly=TRUE)
requireNamespace("scales", quietly=TRUE) #For formating values in graphs
requireNamespace("RColorBrewer", quietly=TRUE)
# requireNamespace("dplyr", quietly=TRUE)
requireNamespace("plyr", quietly=TRUE)
# requireNamespace("reshape2", quietly=TRUE) #For converting wide to long
# requireNamespace("mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.

# @knitr declare_globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values

path_input <- "./data-phi-free/derived/motor-trend-car-test.rds"

histogram_discrete <- function(
  d_observed,
  variable_name,
  levels_to_exclude   = character(0),
  main_title          = variable_name,
  x_title             = NULL,
  y_title             = "Number of Included Records",
  text_size_percentage= 6,
  bin_width           = 1L) {

  d_observed <- as.data.frame(d_observed) #Hack so dplyr datasets don't mess up things
  if( !base::is.factor(d_observed[, variable_name]) )
    d_observed[, variable_name] <- base::factor(d_observed[, variable_name])

  d_observed$IV <- base::ordered(d_observed[, variable_name], levels=rev(levels(d_observed[, variable_name])))

  dsCount <- plyr::count(d_observed, vars=c("IV"))
  # if( base::length(levels_to_exclude)>0 ) { }
  dsCount <- dsCount[!(dsCount$IV %in% levels_to_exclude), ]

  dsSummary <- plyr::ddply(dsCount, .variables=NULL, transform, Count=freq, Proportion = freq/sum(freq) )
  dsSummary$Percentage <- base::paste0(base::round(dsSummary$Proportion*100), "%")

  y_title <- base::paste0(y_title, " (n=", scales::comma(base::sum(dsSummary$freq)), ")")

  g <- ggplot(dsSummary, aes_string(x="IV", y="Count", fill="IV", label="Percentage")) +
    geom_bar(stat="identity") +
    geom_text(stat="identity", size=text_size_percentage, hjust=.8) +
    scale_y_continuous(labels=scales::comma_format()) +
    labs(title=main_title, x=x_title, y=y_title) +
    coord_flip()

  theme  <- theme_light(base_size=14) +
    theme(legend.position = "none") +
    theme(axis.text.x=element_text(colour="gray40")) +
    theme(axis.title.x=element_text(colour="gray40")) +
    theme(axis.text.y=element_text(size=14)) +
    theme(panel.border = element_rect(colour="gray80")) +
    theme(axis.ticks.length = grid::unit(0, "cm"))

  return( g + theme )
}
histogram_continuous <- function(
  d_observed,
  variable_name,
  bin_width      = NULL,
  main_title     = variable_name,
  x_title        = paste0(variable_name, " (each bin is ", scales::comma(bin_width), " units wide)"),
  y_title        = "Frequency",
  rounded_digits = 0L
  ) {

  d_observed <- as.data.frame(d_observed) #Hack so dplyr datasets don't mess up things
  d_observed <- d_observed[!base::is.na(d_observed[, variable_name]), ]

  ds_mid_points <- base::data.frame(label=c("italic(X)[50]", "bar(italic(X))"), stringsAsFactors=FALSE)
  ds_mid_points$value <- c(stats::median(d_observed[, variable_name]), base::mean(d_observed[, variable_name]))
  ds_mid_points$value_rounded <- base::round(ds_mid_points$value, rounded_digits)

  g <- ggplot(d_observed, aes_string(x=variable_name)) +
    geom_bar(stat="bin", bin_width=bin_width, fill="gray70", color="gray90", position=position_identity()) +
    geom_vline(xintercept=ds_mid_points$value, color="gray30") +
    geom_text(data=ds_mid_points, aes_string(x="value", y=0, label="value_rounded"), color="tomato", hjust=c(1, 0), vjust=.5) +
    scale_x_continuous(labels=scales::comma_format()) +
    scale_y_continuous(labels=scales::comma_format()) +
    labs(title=main_title, x=x_title, y=y_title) +
    theme_light() +
    theme(axis.ticks.length = grid::unit(0, "cm"))

  ds_mid_points$top <- stats::quantile(ggplot2::ggplot_build(g)$panel$ranges[[1]]$y.range, .8)
  g <- g + ggplot2::geom_text(data=ds_mid_points, ggplot2::aes_string(x="value", y="top", label="label"), color="tomato", hjust=c(1, 0), parse=TRUE)
  return( g )
}

# @knitr load_data ---------------------------------------------------------------
ds <- readRDS(path_input) # 'ds' stands for 'datasets'

# @knitr tweak_data --------------------------------------------------------------
#
# dropInfantWeightForGestationalAgeCategorySgaOrMissing <- (is.na(ds$InfantWeightForGestationalAgeCategory) | ds$InfantWeightForGestationalAgeCategory=="Sga")
# cat("Number of patients excluded b/c Missing or `SGA` for InfantWeightForGestationalAgeCategory: ", sum(dropInfantWeightForGestationalAgeCategorySgaOrMissing, na.rm=T))
# ds <- ds[!dropInfantWeightForGestationalAgeCategorySgaOrMissing, ]
# ds$InfantWeightForGestationalAgeCategory <- droplevels(ds$InfantWeightForGestationalAgeCategory)
#
# cat("Number of infants excluded b/c premature age: ", sum(ds$PrematureInfant, na.rm=T))
# ds <- ds[!ds$PrematureInfant, ]
#
# #Define the palettes
# colorCenter <- RColorBrewer::brewer.pal(n=3, name="Pastel1")[2:1]
# names(colorCenter) <- levels(ds$Center)
# colorCenterLight <- adjustcolor(colorCenter, alpha.f=.5)
#
# # Create a dataset containing only OUHSC patients
# dsOuhsc <- ds[ds$Center=="OUHSC", ]
#
# #Remove variables no longer necessary
# rm(dropInfantWeightForGestationalAgeCategorySgaOrMissing)
# ds$PrematureInfant <- NULL

# @knitr marginals ---------------------------------------------------------------
# Inspect continuous variables
histogram_continuous(d_observed=ds, variable_name="QuarterMileInSeconds", bin_width=.5, rounded_digits=1)
histogram_continuous(d_observed=ds, variable_name="DisplacementInchesCubed", bin_width=50, rounded_digits=1)

# Inspect discrete/categorical variables
histogram_discrete(d_observed=ds, variable_name="CarburetorCountF")
histogram_discrete(d_observed=ds, variable_name="ForwardGearCountF")

# @knitr scatterplots ------------------------------------------------------------
g1 <- ggplot(ds, aes(x=GrossHorsepower, y=QuarterMileInSeconds, color=ForwardGearCountF)) +
  geom_smooth(method="loess", span=2) +
  geom_point(shape=1) +
  theme_light() +
  theme(axis.ticks.length = grid::unit(0, "cm"))
g1

g1 %+% aes(color=CarburetorCountF)
g1 %+% aes(color=CylinderCount)
g1 %+% aes(color=factor(CylinderCount))

g1 %+% aes(x=MilesPerGallon)
g1 %+% aes(x=MilesPerGallon, color=CarburetorCountF)
g1 %+% aes(x=MilesPerGallon, color=factor(CylinderCount))

# @knitr models ------------------------------------------------------------------
cat("============= Simple model that's just an intercept. =============")
m0 <- lm(QuarterMileInSeconds ~ 1, data=ds)
summary(m0)

cat("============= Model includes one predictor. =============")
m1 <- lm(QuarterMileInSeconds ~ 1 + MilesPerGallon, data=ds)
summary(m1)

cat("The one predictor is significantly tighter.")
anova(m0, m1)

cat("============= Model includes two predictors. =============")
m2 <- lm(QuarterMileInSeconds ~ 1 + MilesPerGallon + ForwardGearCountF, data=ds)
summary(m2)

cat("The two predictor is significantly tighter.")
anova(m1, m2)
