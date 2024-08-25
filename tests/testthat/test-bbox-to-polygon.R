test_that("`bbox_to_polygon` converts bounding box to correct polygon", {
  # Define a bounding box as a matrix
  bbox <- matrix(
    c(136.90090, 35.16377, 136.91590, 35.17377),
    nrow = 2, dimnames = list(c("x", "y"), c("min", "max"))
  )

  # Convert the bounding box to a polygon
  polygon <- bbox_to_polygon(bbox)

  # Extract the coordinates of the polygon
  actual_coords <- unname(polygon[[1]])

  # Define the expected coordinates of the polygon
  expected_coords <- matrix(
    c(
      136.9009, 35.16377,
      136.9159, 35.16377,
      136.9159, 35.17377,
      136.9009, 35.17377,
      136.9009, 35.16377
    ),
    ncol = 2, byrow = TRUE
  )

  # Assert that the actual coordinates match the expected coordinates
  expect_equal(actual_coords, expected_coords)
})
