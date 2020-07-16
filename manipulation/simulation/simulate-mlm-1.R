# knitr::stitch_rmd(script="manipulation/simulation/simulate-mlm-1.R", output="stitched-output/manipulation/simulation/simulate-mlm-1.md") # dir.create("stitched-output/manipulation/simulation", recursive=T)
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
# library("ggplot2")

# Import only certain functions of a package into the search path.
import::from("magrittr", "%>%")

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"        )
requireNamespace("tidyr"        )
requireNamespace("dplyr"        ) # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("rlang"        ) # Language constructs, like quosures
requireNamespace("testit"       ) # For asserting conditions meet expected patterns/conditions.
requireNamespace("checkmate"    ) # For asserting conditions meet expected patterns/conditions. # remotes::install_github("mllg/checkmate")
requireNamespace("DBI"          ) # Database-agnostic interface
requireNamespace("RSQLite"      ) # Lightweight database for non-PHI data.
requireNamespace("OuhscMunge"   ) # remotes::install_github(repo="OuhscBbmc/OuhscMunge")

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
config                         <- config::get()
set.seed(453)
figure_path <- 'stitched-output/manipulation/simulation/simulate-mlm-1/'

subject_count       <- 20
wave_count          <- 10

possible_year_start <- 2000:2005
possible_age_start  <- 55:75
possible_county_id  <- c(51L, 55L, 72L)
possible_county_index  <- seq_along(possible_county_id)
possible_gender_id     <- c(1L, 2L, 255L)
possible_race          <- c(
  "American Indian/Alaska Native",
  "Asian",
  "Native Hawaiian or Other Pacific Islander",
  "Black or African American",
  "White",
  "More than One Race",
  "Unknown or Not Reported"
)
possible_ethnicity <- c(
  "Not Hispanic or Latino",
  "Hispanic or Latino",
  "Unknown/Not Reported Ethnicity"
)
possible_date_offset    <- 30:120   # Add between 30 & 120 days to Jan 1, to get the exact visit date.

int_county          <- c(2, 2.1, 4)
slope_county        <- c(-.04, -.06, -.2)

cor_factor_1_vs_2   <- c(.3, .005)          # Int & slope
loadings_factor_1   <- c(.4, .5, .6)
loadings_factor_2   <- c(.3, .4, .1)
sigma_factor_1      <- c(.1, .2, .1)
sigma_factor_2      <- c(.2, .3, .5)


# ---- load-data ---------------------------------------------------------------

# ---- tweak-data --------------------------------------------------------------

# ---- generate ----------------------------------------------------------------
ds_subject <-
  tibble::tibble(
    subject_id      = factor(1000 + seq_len(subject_count)),
    year_start      = sample(possible_year_start, size=subject_count, replace=T),
    age_start       = sample(possible_age_start , size=subject_count, replace=T),
    county_index    = sample(possible_county_index , size=subject_count, replace=T),
    county_id       = possible_county_id[county_index],

    gender_id       = sample(possible_gender_id , size=subject_count, replace=T, prob=c(.4, .5, .1)),
    race            = sample(possible_race      , size=subject_count, replace=T),
    ethnicity       = sample(possible_ethnicity , size=subject_count, replace=T)

  ) %>%
  dplyr::mutate(
    int_factor_1    = int_county[county_index]   + rnorm(n=subject_count, mean=10.0, sd=2.0),
    slope_factor_1  = slope_county[county_index] + rnorm(n=subject_count, mean= 0.05, sd=0.04),

    int_factor_2    = rnorm(n=subject_count, mean=5.0, sd=0.8) + (cor_factor_1_vs_2[1] * int_factor_1),
    slope_factor_2  = rnorm(n=subject_count, mean= 0.03, sd=0.02) + (cor_factor_1_vs_2[2] * int_factor_1)
  )
ds_subject

ds <-
  tidyr::crossing(
    subject_id      = ds_subject$subject_id,
    wave_id         = seq_len(wave_count)
  ) %>%
  dplyr::right_join(ds_subject, by="subject_id") %>%
  dplyr::mutate(
    year            = wave_id + year_start - 1L,
    age             = wave_id + age_start  - 1L,

    date_at_visit   = as.Date(ISOdate(year, 1, 1) + lubridate::days(sample(possible_date_offset, size=dplyr::n(), replace=T)))
  ) %>%
  dplyr::mutate( # Generate cognitive manifest variables (ie, from factor 1)
    cog_1           =
      (int_factor_1 * loadings_factor_1[1]) +
      slope_factor_1 * wave_id +
      rnorm(n=dplyr::n(), mean=0, sd=sigma_factor_1[1]),
    cog_2           =
      (int_factor_1 * loadings_factor_1[2]) +
      slope_factor_1 * wave_id +
      rnorm(n=dplyr::n(), mean=0, sd=sigma_factor_1[2]),
    cog_3           =
      (int_factor_1 * loadings_factor_1[3]) +
      slope_factor_1 * wave_id +
      rnorm(n=dplyr::n(), mean=0, sd=sigma_factor_1[3])
  ) %>%
  dplyr::mutate( # Generate physical manifest variables (ie, from factor 2)
    phys_1           =
      (int_factor_2 * loadings_factor_2[1]) +
      slope_factor_2 * wave_id +
      rnorm(n=dplyr::n(), mean=0, sd=sigma_factor_2[1]),
    phys_2           =
      (int_factor_2 * loadings_factor_2[2]) +
      slope_factor_2 * wave_id +
      rnorm(n=dplyr::n(), mean=0, sd=sigma_factor_2[2]),
    phys_3           =
      (int_factor_2 * loadings_factor_2[3]) +
      slope_factor_2 * wave_id +
      rnorm(n=dplyr::n(), mean=0, sd=sigma_factor_2[3])
  ) %>%
  dplyr::mutate( # Keep tha manifest variables positive (which will throw off the correlations)
    cog_1   = pmax(0, cog_1),
    cog_2   = pmax(0, cog_2),
    cog_3   = pmax(0, cog_3),
    phys_1  = pmax(0, phys_1),
    phys_2  = pmax(0, phys_2),
    phys_3  = pmax(0, phys_3)
  ) %>%
  dplyr::mutate( # Don't simulate unrealistically precise manfiest variables
    int_factor_1    = round(int_factor_1  , 3),
    slope_factor_1  = round(slope_factor_1, 3),
    int_factor_2    = round(int_factor_2  , 3),
    slope_factor_2  = round(slope_factor_2, 3),

    cog_1   = round(cog_1   , 1),
    cog_2   = round(cog_2   , 1),
    cog_3   = round(cog_3   , 1),
    phys_1  = round(phys_1  , 1),
    phys_2  = round(phys_2  , 1),
    phys_3  = round(phys_3  , 1)
  ) %>%
  dplyr::select(-year_start)

ds

# ---- elongate --------------------------------------------------------------------
ds_long <-
  ds %>%
  dplyr::select(
    subject_id,
    wave_id,
    year,
    date_at_visit,
    age,
    county_id,
    cog_1,
    cog_2,
    cog_3,
    phys_1,
    phys_2,
    phys_3
  ) %>%
  tidyr::gather(
    key   = manifest,
    value = value, -subject_id, -wave_id, -year, -age, -county_id, -date_at_visit
  )


# ---- inspect, fig.width=10, fig.height=6, fig.path=figure_path -----------------------------------------------------------------
library(ggplot2)

ggplot(ds_long, aes(x=wave_id, y=value, color=subject_id)) + #, ymin=0
  geom_line() +
  facet_wrap("manifest", ncol=3, scales="free_y") +
  theme_minimal() +
  theme(legend.position="none")

last_plot() %+% aes(x=year)
last_plot() %+% aes(x=date_at_visit)
last_plot() %+% aes(x=age)

ggplot(ds, aes(x=year, y=cog_1, color=factor(county_id), group=subject_id)) +
  geom_line() +
  theme_minimal() +
  theme(legend.position="top")

# ---- verify-values -----------------------------------------------------------
# OuhscMunge::verify_value_headstart(ds_subject)
checkmate::assert_factor(   ds_subject$subject_id     , any.missing=F                          , unique=T)
checkmate::assert_integer(  ds_subject$county_id      , any.missing=F , lower=51, upper=72     )
checkmate::assert_integer(  ds_subject$gender_id      , any.missing=F , lower=1, upper=255     )
checkmate::assert_character(ds_subject$race           , any.missing=F , pattern="^.{5,41}$"    )
checkmate::assert_character(ds_subject$ethnicity      , any.missing=F , pattern="^.{18,30}$"   )

# OuhscMunge::verify_value_headstart(ds)
checkmate::assert_factor(  ds$subject_id        , any.missing=F                          )
checkmate::assert_integer( ds$wave_id           , any.missing=F , lower=1, upper=10      )
checkmate::assert_integer( ds$year              , any.missing=F , lower=2000, upper=2014 )
checkmate::assert_date(    ds$date_at_visit     , any.missing=F , lower=as.Date("2000-01-01"), upper=as.Date("2018-12-31") )
checkmate::assert_integer( ds$age               , any.missing=F , lower=55, upper=85     )
checkmate::assert_integer( ds$county_id         , any.missing=F , lower=1, upper=77      )

checkmate::assert_numeric( ds$int_factor_1      , any.missing=F , lower=4, upper=20      )
checkmate::assert_numeric( ds$slope_factor_1    , any.missing=F , lower=-1, upper=1      )
checkmate::assert_numeric( ds$int_factor_2      , any.missing=F , lower=6, upper=20      )
checkmate::assert_numeric( ds$slope_factor_2    , any.missing=F , lower=0, upper=1       )

checkmate::assert_numeric( ds$cog_1             , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$cog_2             , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$cog_3             , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$phys_1            , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$phys_2            , any.missing=F , lower=0, upper=20      )
checkmate::assert_numeric( ds$phys_3            , any.missing=F , lower=0, upper=20      )

subject_wave_combo   <- paste(ds$subject_id, ds$wave_id)
checkmate::assert_character(subject_wave_combo, pattern  ="^\\d{4} \\d{1,2}$"   , any.missing=F, unique=T)

# ---- specify-columns-to-upload -----------------------------------------------
# Print colnames that `dplyr::select()`  should contain below:
#   cat(paste0("    ", colnames(ds), collapse=",\n"))
#   cat(paste0("    ", colnames(ds_subject), collapse=",\n"))

ds_slim <-
  ds %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(
    subject_id,
    wave_id,
    # year,
    date_at_visit,
    age, county_id,
    int_factor_1, slope_factor_1,
    cog_1 , cog_2 , cog_3,
    phys_1, phys_2, phys_3
  )
ds_slim

ds_slim_subject <-
  ds_subject %>%
  # dplyr::slice(1:100) %>%
  dplyr::select(
    subject_id,
    county_id, # May intentionally exclude this from the output, to mimic what the ellis has to do sometimes.
    gender_id,
    race,
    ethnicity
  )
ds_slim


# ---- save-to-disk ------------------------------------------------------------
# If there's no PHI, a rectangular CSV is usually adequate, and it's portable to other machines and software.
readr::write_csv(ds_slim        , config$path_mlm_1_raw)
readr::write_csv(ds_slim_subject, config$path_subject_1_raw)
