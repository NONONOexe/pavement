clean_data <- function() {
  unlink(here::here("data", "*.rda"))
}

create_data <- function() {
  source(here::here("data-raw", "osm_highway_values.R"))
  source(here::here("data-raw", "sample_roads.R"))
  source(here::here("data-raw", "sample_accidents.R"))
  source(here::here("data-raw", "jdg2011_datum.R"))

  usethis::use_data(
    osm_highway_values,
    sample_roads,
    sample_accidents,
    jdg2011_datum,
    overwrite = TRUE
  )
}

clean_data()
create_data()
