library(sf)
library(pavement)
library(usethis)
library(here)

clean_data <- function() {
  unlink(here("data", "*.rda"))
}

create_data <- function() {
  source(here("data-raw", "osm_highway_values.R"))
  source(here("data-raw", "sample_roads.R"))

  use_data(
    osm_highway_values,
    sample_roads,
    overwrite = TRUE
  )
}

clean_data()
create_data()
