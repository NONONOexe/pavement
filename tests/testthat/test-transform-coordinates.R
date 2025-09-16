test_that("`transform_to_cartesian` works with valid input", {
  points <- create_points(136.9024, 35.1649, crs = 4326)

  transformed <- transform_to_cartesian(points)

  expect_equal(sf::st_crs(transformed)[[1]], "EPSG:6675")
  expect_equal(
    unname(round(sf::st_coordinates(transformed), digit = 2))[1,],
    c(-24073.54, -92614.18)
  )
})

test_that("`transform_to_geographic` works with valid input", {
  points <- create_points(-24073.54, -92614.18, crs = 6675)

  transformed <- transform_to_geographic(points)

  expect_equal(sf::st_crs(transformed)[[1]], "EPSG:4326")
  expect_equal(
    unname(round(sf::st_coordinates(transformed), digit = 4))[1,],
    c(136.9024, 35.1649)
  )
})
