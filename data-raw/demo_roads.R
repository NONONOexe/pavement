# Define a simple roads object for demonstration and testing
demo_roads <- st_sf(
  id       = sprintf("rd_%04x", 1:6),
  layer    = c(1, NA, NA, NA, NA, NA),
  geometry = st_sfc(
    create_linestring(0, 0, 3, 0, 4, 3),
    create_linestring(0, 1, 7, 1),
    create_linestring(2, 3, 1, 4, 0, 3, 1, 2, 2, 3),
    create_linestring(2, 3, 4, 3),
    create_linestring(4, 3, 7, 3),
    create_linestring(6, 0, 6, 5)
  )
)
