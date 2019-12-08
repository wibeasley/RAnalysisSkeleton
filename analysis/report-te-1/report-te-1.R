rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("something-something.R")

# ---- load-packages -----------------------------------------------------------
library(ggplot2)  # For graphing
library(lme4)     # For mlms
import::from("magrittr", "%>%")
requireNamespace("dplyr")
# requireNamespace("RColorBrewer")
# requireNamespace("scales") #For formating values in graphs
# requireNamespace("mgcv) #For the Generalized Additive Model that smooths the longitudinal graphs.
# requireNamespace("TabularManifest") # remotes::install_github("Melinae/TabularManifest")

# ---- declare-globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values
config                      <- config::get()

# ---- load-data ---------------------------------------------------------------
ds_county       <- readr::read_rds(config$path_te_county)
ds_county_month <- readr::read_rds(config$path_te_county_month)

# ---- tweak-data --------------------------------------------------------------

# ---- marginals-county ---------------------------------------------------------------
TabularManifest::histogram_discrete(d_observed=ds_county, variable_name="county")
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="fte", bin_width=1, rounded_digits = 1)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="cog_1_count", bin_width=1, rounded_digits = 1)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="cog_1", bin_width=.5, rounded_digits=2)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="cog_2", bin_width=.5, rounded_digits=2)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="cog_3", bin_width=.5, rounded_digits=2)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="phys_1", bin_width=.5, rounded_digits=2)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="phys_2", bin_width=.5, rounded_digits=2)
TabularManifest::histogram_continuous(d_observed=ds_county, variable_name="phys_3", bin_width=.5, rounded_digits=2)

# ---- marginals-county-month ---------------------------------------------------------------
ggplot(ds_county_month, aes(x=month)) +
  geom_histogram(binwidth = 365.25/12, color="gray60", fill="#88888833") +
  theme_light()

TabularManifest::histogram_continuous(d_observed=ds_county_month, variable_name="fte", bin_width=.5, rounded_digits = 1)
TabularManifest::histogram_discrete(d_observed=ds_county_month, variable_name="fte_approximated")

# This helps start the code for graphing each variable.
#   - Make sure you change it to `histogram_continuous()` for the appropriate variables.
#   - Make sure the graph doesn't reveal PHI.
#   - Don't graph the IDs (or other uinque values) of large datasets.  The graph will be worth and could take a long time on large datasets.
# for(column in colnames(ds)) {
#   cat('TabularManifest::histogram_discrete(ds, variable_name="', column,'")\n', sep="")
# }

# ---- scatterplots ------------------------------------------------------------

# Graph each county-month
ggplot(ds_county_month, aes(x=month, y=fte, group=factor(county_id), color=factor(county_id), shape=fte_approximated, ymin=0)) +
  geom_point(position=position_jitter(height=.05, width=5), size=4, na.rm=T) +
  # geom_text(aes(label=county_month_id)) +
  geom_line(position=position_jitter(height=.1, width=5)) +
  scale_shape_manual(values=c("TRUE"=21, "FALSE"=NA)) +
  theme_light() +
  guides(color = guide_legend(ncol=4, override.aes = list(size=3, alpha = 1))) +
  guides(shape = guide_legend(ncol=2, override.aes = list(size=3, alpha = 1))) +
  labs(title="FTE sum each month (by county)", y="Sum of FTE for County")

last_plot() +
  coord_cartesian(ylim=c(0, 5)) +
  theme(legend.position = "none")
  labs(title="Zoomed: FTE sum each month (by county)", y="Sum of FTE for County")


# ---- models ------------------------------------------------------------------
cat("============= Simple model that's just an intercept. =============")
m0 <- lm(fte ~ 1, data=ds_county_month)
summary(m0)

cat("============= Model includes one predictor (ie, month). =============")
m1 <- lm(fte ~ 1 + month, data=ds_county_month)
summary(m1)

cat("The one predictor is NOT significantly tighter.")
anova(m0, m1)

cat("============= MLM for county. =============")
m2 <- lmer(fte ~ 1 + (1 | county), data=ds_county_month)
summary(m2)

cat("============= MLM adds month. =============")
m3 <- lmer(fte ~ 1 + month + (1 | county), data=ds_county_month)
summary(m3)

cat("Including the Month predictor in the MLM is significantly tighter.")
anova(m2, m3)

# ---- model-results-table  -----------------------------------------------
summary(m3)$coef %>%
  knitr::kable(
    digits      = 2,
    format      = "markdown"
  )

# Uncomment the next line for a dynamic, JavaScript [DataTables](https://datatables.net/) table.
# DT::datatable(round(summary(m2)$coef, digits = 2), options = list(pageLength = 2))
