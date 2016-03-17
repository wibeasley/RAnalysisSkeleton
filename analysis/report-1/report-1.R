rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("./SomethingSomething.R")

# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
# library(magrittr) #Pipes
requireNamespace("knitr")
requireNamespace("scales") #For formating values in graphs
requireNamespace("RColorBrewer")
# requireNamespace("dplyr")
requireNamespace("plyr")
# requireNamespace("reshape2") #For converting wide to long
# requireNamespace("mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.
# requireNamespace("TabularManifest") # devtools::install_github("Melinae/TabularManifest")

# ---- declare-globals ---------------------------------------------------------
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

  d_observed$iv <- base::ordered(d_observed[, variable_name], levels=rev(levels(d_observed[, variable_name])))

  ds_count <- plyr::count(d_observed, vars=c("iv"))
  # if( base::length(levels_to_exclude)>0 ) { }
  ds_count <- ds_count[!(ds_count$iv %in% levels_to_exclude), ]

  ds_summary <- plyr::ddply(ds_count, .variables=NULL, transform, count=freq, proportion = freq/sum(freq) )
  ds_summary$percentage <- base::paste0(base::round(ds_summary$proportion*100), "%")

  y_title <- base::paste0(y_title, " (n=", scales::comma(base::sum(ds_summary$freq)), ")")

  g <- ggplot(ds_summary, aes_string(x="iv", y="count", fill="iv", label="percentage")) +
    geom_bar(stat="identity") +
    geom_text(stat="identity", size=text_size_percentage, hjust=.8) +
    scale_y_continuous(labels=scales::comma_format()) +
    labs(title=main_title, x=x_title, y=y_title) +
    coord_flip()

  theme  <- theme_light(base_size=14) +
    theme(legend.position = "none") +
    theme(panel.grid.major.y=element_blank(), panel.grid.minor.y=element_blank()) +
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
    geom_histogram(binwidth=bin_width, fill="gray70", color="gray90", position=position_identity()) +
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

# ---- load-data ---------------------------------------------------------------
ds <- readRDS(path_input) # 'ds' stands for 'datasets'

# ---- tweak-data --------------------------------------------------------------
#
# drop_infant_weight_for_gestational_age_category_sga_or_missing <- (is.na(ds$infant_weight_for_gestational_age_category) | ds$infant_weight_for_gestational_age_category=="Sga")
# cat("Number of patients excluded b/c Missing or `SGA` for infant_weight_for_gestational_age_category: ", sum(drop_infant_weight_for_gestational_age_category_sga_or_missing, na.rm=T))
# ds <- ds[!drop_infant_weight_for_gestational_age_category_sga_or_missing, ]
# ds$infant_weight_for_gestational_age_category <- droplevels(ds$infant_weight_for_gestational_age_category)
#
# cat("Number of infants excluded b/c premature age: ", sum(ds$premature_infant, na.rm=T))
# ds <- ds[!ds$premature_infant, ]
#
# #Define the palettes
# color_center <- RColorBrewer::brewer.pal(n=3, name="Pastel1")[2:1]
# names(color_center) <- levels(ds$center)
# color_center_light <- adjustcolor(color_center, alpha.f=.5)
#
# # Create a dataset containing only OUHSC patients
# dsOuhsc <- ds[ds$center=="OUHSC", ]
#
# #Remove variables no longer necessary
# rm(drop_infant_weight_for_gestational_age_category_sga_or_missing)
# ds$premature_infant <- NULL

# ---- marginals ---------------------------------------------------------------
# Inspect continuous variables
histogram_continuous(d_observed=ds, variable_name="quarter_mile_in_seconds", bin_width=.5, rounded_digits=1)
histogram_continuous(d_observed=ds, variable_name="displacement_inches_cubed", bin_width=50, rounded_digits=1)

# Inspect discrete/categorical variables
histogram_discrete(d_observed=ds, variable_name="carburetor_count_f")
histogram_discrete(d_observed=ds, variable_name="forward_gear_count_f")

# This helps start the code for graphing each variable.  
#   - Make sure you change it to `histogram_continuous()` for the appropriate variables.
#   - Make sure the graph doesn't reveal PHI.
#   - Don't graph the IDs (or other uinque values) of large datasets.  The graph will be worth and could take a long time on large datasets.
# for(column in colnames(ds)) {
#   cat('TabularManifest::histogram_discrete(ds, variable_name="', column,'")\n', sep="")
# }

# ---- scatterplots ------------------------------------------------------------
g1 <- ggplot(ds, aes(x=gross_horsepower, y=quarter_mile_in_seconds, color=forward_gear_count_f)) +
  geom_smooth(method="loess", span=2) +
  geom_point(shape=1) +
  theme_light() +
  theme(axis.ticks.length = grid::unit(0, "cm"))
g1

g1 %+% aes(color=carburetor_count_f)
g1 %+% aes(color=cylinder_count)
g1 %+% aes(color=factor(cylinder_count))

g1 %+% aes(x=miles_per_gallon)
g1 %+% aes(x=miles_per_gallon, color=carburetor_count_f)
g1 %+% aes(x=miles_per_gallon, color=factor(cylinder_count))

# ---- models ------------------------------------------------------------------
cat("============= Simple model that's just an intercept. =============")
m0 <- lm(quarter_mile_in_seconds ~ 1, data=ds)
summary(m0)

cat("============= Model includes one predictor. =============")
m1 <- lm(quarter_mile_in_seconds ~ 1 + miles_per_gallon, data=ds)
summary(m1)

cat("The one predictor is significantly tighter.")
anova(m0, m1)

cat("============= Model includes two predictors. =============")
m2 <- lm(quarter_mile_in_seconds ~ 1 + miles_per_gallon + forward_gear_count_f, data=ds)
summary(m2)

cat("The two predictor is significantly tighter.")
anova(m1, m2)
