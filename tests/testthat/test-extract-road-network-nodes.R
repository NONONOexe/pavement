nodes <- extract_road_network_nodes(sample_roads)

test_that("`extract_road_network_nodes` works correctly", {
  expected_node_points <- create_points(
    0, 0, 4, 3, 6, 1, 0, 1, 7, 1, 2, 3, 6, 3, 7, 3, 6, 0, 6, 5
  )

  expect_equal(nodes$geometry, expected_node_points)
})

test_that("IDs are in ascending order", {
  ids <- nodes$id
  expect_true(all(ids == sort(ids)))
})
