test_that("`create_polygon` works with valid input", {
  polygon <- create_polygon(
    136.9009, 35.16377,
    136.9159, 35.16377,
    136.9159, 35.17377,
    136.9009, 35.17377,
    crs = 4326
  )
  expect_s3_class(polygon, "sfc_POLYGON")
  expect_equal(length(polygon), 1)
  expect_equal(st_crs(polygon)[[1]], "EPSG:4326")
})
