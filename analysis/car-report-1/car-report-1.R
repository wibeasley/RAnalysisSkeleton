rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("SomethingSomething.R")

# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
import::from("magrittr", "%>%")
requireNamespace("dplyr")
# requireNamespace("RColorBrewer")
# requireNamespace("scales") #For formating values in graphs
# requireNamespace("mgcv) #For the Generalized Additive Model that smooths the longitudinal graphs.
# requireNamespace("TabularManifest") # remotes::install_github("Melinae/TabularManifest")

# ---- declare-globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values
# config                      <- config::get()
# path_input                  <- config$path_car_derived
# Uncomment the lines above and delete the one below if value is stored in 'config.yml'.

path_input <- "data-public/derived/car.rds"

# The two graphing functions are copied from https://github.com/Melinae/TabularManifest.
histogram_discrete <- function(
  d_observed,
  variable_name,
  levels_to_exclude   = character(0),
  main_title          = variable_name,
  x_title             = NULL,
  y_title             = "Number of Included Records",
  text_size_percentage= 6,
  bin_width           = 1L,
  font_base_size      = 12
) {

  # Ungroup, in case it comes in grouped.
  d_observed <-
    d_observed %>%
    dplyr::ungroup()

  if( !base::is.factor(d_observed[[variable_name]]) )
    d_observed[[variable_name]] <- base::factor(d_observed[[variable_name]])

  d_observed$iv <- base::ordered(d_observed[[variable_name]], levels=rev(levels(d_observed[[variable_name]])))

  d_count <- dplyr::count(d_observed, iv)
  # if( base::length(levels_to_exclude)>0 ) { }
  d_count <- d_count[!(d_count$iv %in% levels_to_exclude), ]

  d_summary <- d_count %>%
    dplyr::rename(
      count    =  n
    ) %>%
    dplyr::mutate(
      proportion = count / sum(count)
    )
  d_summary$percentage <- base::paste0(base::round(d_summary$proportion*100), "%")

  y_title <- base::paste0(y_title, " (n=", scales::comma(base::sum(d_summary$count)), ")")

  g <-
    ggplot(d_summary, aes_string(x="iv", y="count", fill="iv", label="percentage")) +
    geom_bar(stat="identity") +
    geom_text(stat="identity", size=text_size_percentage, hjust=.8, na.rm=T) +
    scale_y_continuous(labels=scales::comma_format()) +
    labs(title=main_title, x=x_title, y=y_title) +
    coord_flip()

  theme <-
    theme_light(base_size=font_base_size) +
    theme(legend.position       =  "none") +
    theme(panel.grid.major.y    =  element_blank()) +
    theme(panel.grid.minor.y    =  element_blank()) +
    theme(axis.text.y           =  element_text(size=font_base_size + 2L)) +
    theme(axis.text.x           =  element_text(colour="gray40")) +
    theme(axis.title.x          =  element_text(colour="gray40")) +
    theme(panel.border          =  element_rect(colour="gray80")) +
    theme(axis.ticks            =  element_blank())

  return( g + theme )
}
histogram_continuous <- function(
  d_observed,
  variable_name,
  bin_width               = NULL,
  main_title              = base::gsub("_", " ", variable_name, perl=TRUE),
  x_title                 = paste0(variable_name, "\n(each bin is ", scales::comma(bin_width), " units wide)"),
  y_title                 = "Frequency",
  rounded_digits          = 0L,
  font_base_size          = 12
) {

  if( !inherits(d_observed, "data.frame") )
    stop("`d_observed` should inherit from the data.frame class.")

  d_observed <- tidyr::drop_na(d_observed, !! variable_name)

  ds_mid_points               <- base::data.frame(label=c("italic(X)[50]", "bar(italic(X))"), stringsAsFactors=FALSE)
  ds_mid_points$value         <- c(stats::median(d_observed[[variable_name]]), base::mean(d_observed[[variable_name]]))
  ds_mid_points$value_rounded <- base::round(ds_mid_points$value, rounded_digits)

  if( ds_mid_points$value[1] < ds_mid_points$value[2] ) {
    h_just <- c(1.1, -0.1)
  } else {
    h_just <- c(-0.1, 1.1)
  }

  g <-
    d_observed %>%
    ggplot2::ggplot(ggplot2::aes_string(x=variable_name)) +
    ggplot2::geom_histogram(binwidth=bin_width, position=ggplot2::position_identity(), fill="gray70", color="gray90", alpha=.7) +
    ggplot2::geom_vline(xintercept=ds_mid_points$value, color="gray30") +
    ggplot2::geom_text(data=ds_mid_points, ggplot2::aes_string(x="value", y=0, label="value_rounded"), color="tomato", hjust=h_just, vjust=.5, na.rm=T) +
    ggplot2::scale_x_continuous(labels=scales::comma_format()) +
    ggplot2::scale_y_continuous(labels=scales::comma_format()) +
    ggplot2::labs(title=main_title, x=x_title, y=y_title)

  g <- g +
    ggplot2::theme_light(base_size = font_base_size) +
    ggplot2::theme(axis.ticks             = ggplot2::element_blank())

  g <- g + ggplot2::geom_text(data=ds_mid_points, ggplot2::aes_string(x="value", y=Inf, label="label"), color="tomato", hjust=h_just, vjust=2, parse=TRUE)
  return( g )
}

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_rds(path_input) # 'ds' stands for 'datasets'

# ---- tweak-data --------------------------------------------------------------
ds <-
  ds %>%
  dplyr::mutate(
    # Create duplicates of variables as factors (not numbers), which can help with later graphs or analyses.
    #   Admittedly, the labels are a contrived example of a factor, but helps the demo later.
    forward_gear_count_f  = factor(forward_gear_count, levels=3:5, labels=c("Three", "Four", "Five")),
    carburetor_count_f    = factor(carburetor_count),

    ### Create transformations and interactions to help later graphs and models.
    horsepower_by_gear_count_3  = horsepower * (forward_gear_count=="three"),
    horsepower_by_gear_count_4  = horsepower * (forward_gear_count=="four" )
  )

checkmate::assert_factor(   ds$forward_gear_count_f         , any.missing=F                           )
checkmate::assert_factor(   ds$carburetor_count_f           , any.missing=F                           )
checkmate::assert_numeric(  ds$horsepower_by_gear_count_3   , any.missing=F , lower=   0, upper=   0  )
checkmate::assert_numeric(  ds$horsepower_by_gear_count_4   , any.missing=F , lower=   0, upper=   0  )

# ---- marginals ---------------------------------------------------------------
# Inspect continuous variables
histogram_continuous(d_observed=ds, variable_name="quarter_mile_sec", bin_width=.5, rounded_digits=1)
# slightly better function: TabularManifest::histogram_continuous(d_observed=ds, variable_name="quarter_mile_sec", bin_width=.5, rounded_digits=1)
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
g1 <-
  ggplot(ds, aes(x=horsepower, y=quarter_mile_sec, color=forward_gear_count_f)) +
  geom_smooth(method="loess", span=2) +
  geom_point(shape=1) +
  theme_light() +
  theme(axis.ticks = element_blank())
g1

g1 %+% aes(color=cylinder_count)
g1 %+% aes(color=factor(cylinder_count))

ggplot2::qplot(ds$weight_gear_z, color=ds$forward_gear_count_f, geom="density")  # mean(ds$weight_gear_z, na.rm=T)

ggplot(ds, aes(x=weight_gear_z, color=forward_gear_count_f, fill=forward_gear_count_f)) +
  geom_density(alpha=.1) +
  theme_minimal() +
  labs(x=expression(z[gear]))

# ---- models ------------------------------------------------------------------
cat("============= Simple model that's just an intercept. =============")
m0 <- lm(quarter_mile_sec ~ 1, data=ds)
summary(m0)

cat("============= Model includes one predictor. =============")
m1 <- lm(quarter_mile_sec ~ 1 + miles_per_gallon, data=ds)
summary(m1)

cat("The one predictor is significantly tighter.")
anova(m0, m1)

cat("============= Model includes two predictors. =============")
m2 <- lm(quarter_mile_sec ~ 1 + miles_per_gallon + forward_gear_count_f, data=ds)
summary(m2)

cat("The two predictor is significantly tighter.")
anova(m1, m2)

# ---- model-results-table  -----------------------------------------------
summary(m2)$coef %>%
  knitr::kable(
    digits      = 2,
    format      = "markdown"
  )

# Uncomment the next line for a dynamic, JavaScript [DataTables](https://datatables.net/) table.
# DT::datatable(round(summary(m2)$coef, digits = 2), options = list(pageLength = 2))
