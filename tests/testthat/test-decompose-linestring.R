test_that("`decompose_linestring` correctly decompose a linestring into segments", {
  # Create a linestring object
  linestring <- create_linestring(0, 0, 1, 1, 2, 1, 4, 0)

  # Define the expected segments after decomposition
  expected_segments <- st_sfc(list(
    create_linestring(0, 0, 1, 1),
    create_linestring(1, 1, 2, 1),
    create_linestring(2, 1, 4, 0)
  ))

  # Decompose the linestring using the function
  result <- decompose_linestring(linestring)

  expect_equal(result, expected_segments)
})
