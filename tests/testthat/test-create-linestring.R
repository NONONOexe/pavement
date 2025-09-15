test_that("`create_linestring.numeric` works valid input", {
  linestring <- create_linestring(1, 2, 3, 4, crs = 4326)
  expect_s3_class(linestring, "sfc_LINESTRING")
  expect_equal(length(linestring), 1)
  expect_equal(sf::st_crs(linestring)[[1]], "EPSG:4326")
})

test_that("`create_linestring.coordinates` works with valid input", {
  coordinates <- create_coordinates(1, 2, 3, 4)
  linestring <- create_linestring(coordinates, crs = 4326)
  expect_s3_class(linestring, "sfc_LINESTRING")
  expect_equal(length(linestring), 1)
  expect_equal(sf::st_crs(linestring)[[1]], "EPSG:4326")
})
