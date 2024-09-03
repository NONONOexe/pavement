test_that("`extract_road_network_links` works correctly", {
  expected_link_linestrings <- c(
    create_linestring(0, 0, 3, 0, 4, 3),
    create_linestring(6, 1, 7, 1),
    create_linestring(0, 1, 6, 1),
    create_linestring(2, 3, 1, 4, 0, 3, 1, 2, 2, 3),
    create_linestring(2, 3, 4, 3),
    create_linestring(6, 3, 7, 3),
    create_linestring(4, 3, 6, 3),
    create_linestring(6, 3, 6, 5),
    create_linestring(6, 0, 6, 1),
    create_linestring(6, 1, 6, 3)
  )

  nodes <- extract_road_network_nodes(sample_roads)
  links <- extract_road_network_links(sample_roads, nodes)
  expect_equal(links$geometry, expected_link_linestrings)
})
