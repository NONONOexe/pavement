library(sf)
library(pavement)

source("data-raw/osm_highway_values.R")
source("data-raw/demo_roads.R")

usethis::use_data(
  osm_highway_values,
  demo_roads,
  overwrite = TRUE
)
