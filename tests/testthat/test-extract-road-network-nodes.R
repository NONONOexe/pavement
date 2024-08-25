test_that("`extract_road_network_nodes` works correctly", {
  expected_node_points <- st_sfc(
    st_point(c(0, 0)), st_point(c(4, 3)), st_point(c(6, 1)), st_point(c(0, 1)),
    st_point(c(7, 1)), st_point(c(2, 3)), st_point(c(6, 3)), st_point(c(7, 3)),
    st_point(c(6, 0)), st_point(c(6, 5))
  )

  nodes <- extract_road_network_nodes(demo_roads)
  expect_equal(nodes$geometry, expected_node_points)
})
