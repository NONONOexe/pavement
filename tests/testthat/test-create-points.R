test_that("`create_points.numeric` works valid input", {
  points <- create_points(1, 2, 3, 4, crs = 4326)
  expect_s3_class(points, "sfc_POINT")
  expect_equal(length(points), 2)
  expect_equal(st_crs(points)[[1]], "EPSG:4326")
})

test_that("`create_points.coordinates` works with valid input", {
  coordinates <- create_coordinates(1, 2, 3, 4)
  points <- create_points(coordinates, crs = 4326)
  expect_s3_class(points, "sfc_POINT")
  expect_equal(length(points), 2)
  expect_equal(st_crs(points)[[1]], "EPSG:4326")
})
