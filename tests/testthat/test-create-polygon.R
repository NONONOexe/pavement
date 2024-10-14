test_that("`create_polygon` creates correct polygon from bounding box", {
  # Define a bounding box as a matrix
  bbox <- matrix(
    c(136.90090, 35.16377, 136.91590, 35.17377),
    nrow = 2, dimnames = list(c("x", "y"), c("min", "max"))
  )

  # Convert the bounding box to a polygon
  polygon <- create_polygon(bbox)

  # Extract the coordinates of the polygon
  actual_coords <- st_coordinates(polygon)[, c("X", "Y")]

  # Define the expected coordinates of the polygon
  expected_coords <- matrix(
    c(
      136.9009, 35.16377,
      136.9159, 35.16377,
      136.9159, 35.17377,
      136.9009, 35.17377,
      136.9009, 35.16377
    ),
    ncol = 2, byrow = TRUE, dimnames = list(NULL, c("X", "Y"))
  )

  # Assert that the actual coordinates match the expected coordinates
  expect_equal(actual_coords, expected_coords)
})
