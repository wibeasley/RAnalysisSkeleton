rm(list = ls(all.names = TRUE))

spelling::spell_check_package()
# spelling::update_wordlist()

lintr::lint_package()
lintr::lint_dir(".")
lintr::lint("flow.R")

devtools::document()
devtools::check_man() #Should return NULL
# devtools::clean_vignettes()
# devtools::build_vignettes()

checks_to_exclude <- c(
  "covr",
  # "cyclocomp"#,
  "lintr_line_length_linter"
)
gp <-
  goodpractice::all_checks() |>
  purrr::discard(~(. %in% checks_to_exclude)) |>
  {
    \(checks)
    goodpractice::gp(checks = checks)
  }()
goodpractice::results(gp)
gp

urlchecker::url_check(); urlchecker::url_update()

# devtools::check(force_suggests = FALSE)
devtools::check(cran = TRUE)
