test_that("`create_bbox` works with cardinal coordinates", {
  # Create a bounding box from cardinal coordinates
  bbox <- create_bbox(c(
    north = 35.17377, south = 35.16377,
    east = 136.91590, west = 136.90090
  ))

  # Define the expected bounding box
  expected_bbox <- matrix(
    c(136.90090, 35.16377, 136.91590, 35.17377),
    nrow = 2, dimnames = list(c("x", "y"), c("min", "max"))
  )

  # Check if the created bounding box is equal to the expected bounding box
  expect_equal(bbox, expected_bbox)
})

test_that("`create_bbox` works with center coordinates", {
  # Create a bounding box from center coordinates and size of width and height
  bbox <- create_bbox(c(
    center_lon = 136.90840, center_lat =  35.16877,
    width = 0.015, height = 0.010
  ))

  # Define the expected bounding box
  expected_bbox <- matrix(
    c(136.90090, 35.16377, 136.91590, 35.17377),
    nrow = 2, dimnames = list(c("x", "y"), c("min", "max"))
  )

  # Check if the created bounding box is equal to the expected bounding box
  expect_equal(bbox, expected_bbox)
})
