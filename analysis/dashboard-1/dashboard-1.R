rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
base::source(file="analysis/common/display-1.R") #Load common graphing functions.

# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
library(plotly)
import::from("magrittr", "%>%")
requireNamespace("scales")
requireNamespace("dplyr")
requireNamespace("tidyr") #For converting wide to long
requireNamespace("broom")
requireNamespace("kableExtra")
requireNamespace("TabularManifest") # remotes::install_github("Melinae/TabularManifest")

# ---- declare-globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values
config                         <- config::get()

# desired_models            <- "PAT"
county_id_focus           <- 72L
base_size                 <- 14L


path_in_annotation      <- config$path_annotation
# colors <- c('#0000ff','#ff8000','#ffff99',   '#ff0000' )
palette_county_dark   <- c("Muskogee"="#b0d794"  , "Oklahoma"="#83c1b2"  ,  "Tulsa"="#f4a971"  ) #http://colrd.com/image-dna/28023/
palette_county_light  <- c("Muskogee"="#b0d79433", "Oklahoma"="#83c1b233",  "Tulsa"="#f4a97133")

# ---- load-data ---------------------------------------------------------------
ds                <- readr::read_rds(config$path_mlm_1_derived)
ds_county         <- readr::read_rds(config$path_county_derived)
ds_county_year    <- readr::read_rds(config$path_county_year_derived)

ds_annotation       <- read.csv(path_in_annotation)

# ---- tweak-data --------------------------------------------------------------
ds <-
  ds %>%
  # dplyr::filter(county %in% desired_counties) %>%
  dplyr::mutate(
    emphasis        = dplyr::if_else(county_id == county_id_focus, "focus", "background"),
    focus           = as.integer(county_id == county_id_focus),
    county_id       = factor(county_id)
  )

ds_county <-
  ds_county %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    cog       = cog_1_mean  + cog_2_mean  + cog_3_mean ,
    phys      = phys_1_mean + phys_2_mean + phys_3_mean,
    label     = sprintf("%s mean:\n%3.1f", county, cog)
  ) %>%
  dplyr::mutate(
    emphasis        = dplyr::if_else(county_id == county_id_focus, "focus", "background"),
    focus           = as.integer(county_id == county_id_focus),
    county_id       = factor(county_id)
  )

ds_county_year <-
  ds_county_year %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    emphasis        = dplyr::if_else(county_id == county_id_focus, "focus", "background"),
    focus           = as.integer(county_id == county_id_focus),
    # focus2           = (county_id == county_id_focus),
    # size            = dplyr::if_else(county_id == county_id_focus, 1, .50),
    county_id       = factor(county_id)
  )

county_name_focus   <-
  ds_county %>%
  dplyr::filter(county_id == county_id_focus) %>%
  dplyr::pull(county)

# ---- headline-graph ----------------------------------------------------------
# cat("\n\n\n### Goals Status-- (ALL REPORTING PERIOD)\n\n\n")
ggplot(ds_county, aes(x=county, y=cog, label=label, color=county, fill=county)) +
  geom_bar(stat="identity") +
  geom_label(color="gray30", fill="#88888833", vjust=1.3) +
  scale_color_manual(values=palette_county_dark) +
  scale_fill_manual(values=palette_county_light) +
  theme_light() +
  theme(legend.position="none") +
  theme(panel.grid.major.x = element_blank()) +
  theme(axis.ticks.x=element_blank()) +
  labs(title="Cognitive Outcome by County", x=NULL, y="Cognitive Mean")

# ---- tables-county-year ----------------------------------------------------------
ds_county_year %>%
   dplyr::arrange(desc(year), county) %>%
   dplyr::select(
     county, year, cog_1_mean, cog_2_mean, cog_3_mean, phys_1_mean, phys_2_mean, phys_3_mean
   )%>%
   DT::datatable(
     colnames=gsub("_", " ", colnames(.)),
     options = list(
       pageLength = 16
     )
   ) %>%
  DT::formatCurrency(
    columns  = c(
      "cog_1_mean", "cog_2_mean", "cog_3_mean",
      "phys_1_mean", "phys_2_mean", "phys_3_mean"
    ),
    currency = "",
    digits   = 1
  )

# ---- tables-county ----------------------------------------------------------
ds_county  %>%
  dplyr::arrange(county) %>%
  dplyr::select(
    county, cog_1_mean, cog_2_mean, cog_3_mean, phys_1_mean, phys_2_mean, phys_3_mean
  )%>%
  DT::datatable(
    colnames=gsub("_", " ", colnames(.)),
    options = list(
      pageLength = 16
    )
  ) %>%
  DT::formatCurrency(
    columns  = c(
      "cog_1_mean", "cog_2_mean", "cog_3_mean",
      "phys_1_mean", "phys_2_mean", "phys_3_mean"
    ),
    currency = "",
    digits   = 1
  )

# ---- tables-annotation ----------------------------------------------------------
ds_annotation %>%
  DT::datatable(
    colnames=gsub("_", " ", colnames(.)),
    options = list(
      pageLength = 16
    )
  )


# ---- spaghetti --------------------------------------------
cat("\n\n### Cog 1<br/><b>County-Year</b>\n\n")

ds_county_year %>%
  dplyr::group_by(county) %>%
  plot_ly(
    x = ~year,
    y = ~cog_1_mean,
    type = 'scatter',
    mode = "lines",
    color = ~county,
    colors = palette_county_dark,
    # visible = FALSE,
    size   = ~focus,
    sizes  = c(1, 4),
    text = ~sprintf(
      "<br>For county %s during %4i,<br>the average Cog 1 score was %1.2f.",
      county, year, cog_1_mean
    )
  ) %>%
  # dplyr::ungroup() %>%
  plotly::add_markers(
    size   = ~focus,
    # symbol   = ~emphasis,
    # symbols = c("focus"= "circle", "background"="circle-open"),
    marker = list(size = rep(c(100), each=15), symbol=rep("circle-open", each=15)),
    # marker = list(size = rep(c(100), each=15), marker=rep("circle-open", each=15)),
    # sizes  = c(40, 20),
    showlegend = F,
    text = ~sprintf(
      "<br>For %s county during %4i,<br>the average Cog 1 score was %1.2f.",
      county, year, cog_1_mean
    )
  ) %>%
  # add_trace(type = "scatter", mode = "markers+lines")
  dplyr::ungroup() %>%
  layout(
    # showlegend = FALSE,
    legend = list(orientation = 'h'),
    xaxis = list(title=NA),
    yaxis = list(
      title = "Cog 1",
      titlefont = list(
        family = "Courier New, monospace",
        size = 18,
        color = "#7f7f7f"
      )
    )
  )


cat("\n\n### Cog 2<br/><b>County-Year</b>\n\n")
ds_county_year %>%
  spaghetti_1(
    d                   = .,
    response_variable   = "cog_1_mean",
    time_variable       = "year",
    color_variable      = "county",
    group_variable      = "county",
    facet_variable      = NULL,
    palette             = palette_county_dark,
    path_in_annotation  = path_in_annotation,
    width               = c("focus"=2, "background"=1),
    base_size           = 18
  )

cat("\n\n### Cog 3<br/><b>County-Year</b>\n\n")
ds_county_year %>%
  spaghetti_1(
    d                   = ,
    response_variable   = "cog_3_mean",
    time_variable       = "year",
    color_variable      = "county",
    group_variable      = "county",
    facet_variable      = NULL,
    palette             = palette_county_dark,
    path_in_annotation  = path_in_annotation,
    width               = c("focus"=2, "background"=1),
    base_size           = 14
  ) %>%
  plotly::ggplotly() %>%
  plotly::hide_legend()


cat("\n\n### Cog 1<br/><b>Subject-Year</b>\n\n")
ds %>%
  dplyr::group_by(subject_id) %>%
  plot_ly(
    x = ~year,
    y = ~cog_1,
    type = 'scatter',
    mode = "lines",
    color = ~county,
    colors = palette_county_dark,
    # visible = FALSE,
    size   = ~focus,
    sizes  = c(1, 4),
    text = ~sprintf(
      "<br>For subject %s during %4i<br>(in %s county),<br>the Cog 1 score was %1.2f.",
      subject_id, year, county, cog_1
    )
  ) %>%
  dplyr::ungroup() %>%
  layout(
    # showlegend = FALSE,
    legend = list(orientation = 'h'),
    xaxis = list(title=NA),
    yaxis = list(
      title = "Cog 1",
      titlefont = list(
        family = "Courier New, monospace",
        size = 18,
        color = "#7f7f7f"
      )
    )
  )

# spaghetti_1(
#   d                   = ds,
#   response_variable   = "cog_1",
#   time_variable       = "year",
#   color_variable      = "county",
#   group_variable      = "subject_id",
#   facet_variable      = NULL,
#   palette             = palette_county_dark,
#   path_in_annotation  = path_in_annotation,
#   width               = c("focus"=2, "background"=1),
#   base_size           = 18
# )

cat("\n\n### Cog 2<br/><b>Subject-Year</b>\n\n")
spaghetti_1(
  d                   = ds,
  response_variable   = "cog_2",
  time_variable       = "year",
  color_variable      = "county",
  group_variable      = "subject_id",
  facet_variable      = NULL,
  palette             = palette_county_dark,
  path_in_annotation  = path_in_annotation,
  width               = c("focus"=2, "background"=1),
  base_size           = 18
)

cat("\n\n### Cog 3<br/><b>Subject-Year</b>\n\n")
spaghetti_1(
  d                   = ds,
  response_variable   = "cog_3",
  time_variable       = "year",
  color_variable      = "county",
  group_variable      = "subject_id",
  facet_variable      = NULL,
  palette             = palette_county_dark,
  path_in_annotation  = path_in_annotation,
  width               = c("focus"=2, "background"=1),
  base_size           = 18
) %>%
  plotly::ggplotly() %>%
  plotly::hide_legend()


# ---- marginals ---------------------------------------------------------------
histogram_2(
  d_observed      = ds,
  variable_name   = "cog_1",
  bin_width       = .5,
  rounded_digits  = 1,
  main_title      = NULL,
  tab_title     = "\n\n### <b>Cog 1</b><br/>Collapsing Subject-Year\n\n"
)
histogram_2(
  d_observed    = ds,
  variable_name = "cog_2",
  bin_width     = 1,
  rounded_digits= 1,
  main_title    = NULL,
  tab_title     = "\n\n### <b>Cog 2</b><br/>Collapsing Subject-Year\n\n"
)
histogram_2(
  d_observed    = ds,
  variable_name = "cog_3",
  bin_width     = .2,
  rounded_digits= 2,
  main_title    = NULL,
  tab_title     = "\n\n### <b>Cog 3</b><br/>Collapsing Subject-Year\n\n"
)
