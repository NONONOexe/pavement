test_that("`transform_to_cartesian` works with valid input", {
  points <- create_points(136.9024, 35.1649, crs = 4326)

  transformed <- transform_to_cartesian(points)

  expect_equal(st_crs(transformed)[[1]], "EPSG:6675")
  expect_equal(
    unname(round(st_coordinates(transformed), digit = 2))[1,],
    c(-24073.54, -92614.18)
  )
})
