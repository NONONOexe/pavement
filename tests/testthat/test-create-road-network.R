test_that("`create_road_network.sf` works with valid input", {
  road_network <- create_road_network(sample_roads)

  # Check the structure of the road network
  expect_s3_class(road_network, "road_network")
  expect_contains(names(road_network), c("graph", "nodes", "links", "roads"))
  expect_equal(nrow(road_network$nodes), 10)
  expect_equal(nrow(road_network$links), 10)

  # Check the directed property
  expect_false(igraph::is_directed(road_network$graph))

  # Check the plot function
  expect_silent(plot(road_network))
})

test_that("`create_road_network.sf` works with directed input", {
  road_network <- create_road_network(sample_roads, directed = TRUE)

  # Check the structure of the road network
  expect_s3_class(road_network, "road_network")
  expect_contains(names(road_network), c("graph", "nodes", "links", "roads"))
  expect_equal(nrow(road_network$nodes), 10)
  expect_equal(nrow(road_network$links), 10)

  # Check the directed property
  expect_true(igraph::is_directed(road_network$graph))

  # Check the plot function
  expect_silent(plot(road_network, mode = "graph"))
})

test_that("`create_road_network.sf` works with events", {
  road_network <- create_road_network(sample_roads, events = sample_accidents)

  # Check the structure of the road network
  expect_s3_class(road_network, "road_network")
  expect_contains(names(road_network),
                  c("graph", "nodes", "links", "roads", "events"))
  expect_equal(nrow(road_network$nodes), 10)
  expect_equal(nrow(road_network$links), 10)
  expect_equal(nrow(road_network$events), 10)

  # Check the plot function
  expect_silent(plot(road_network, mode = "event"))
})

test_that("`print.road_network` works", {
  road_network <- create_road_network(sample_roads)

  # Check the print function
  expect_output(print(road_network), "Road network")
  expect_output(print(road_network), "Nodes:")
  expect_output(print(road_network), "Links:")
})

test_that("`summary.road_network` works", {
  road_network <- create_road_network(sample_roads)

  # Check the summary function
  expect_output(summary(road_network), "Road network summary")
  expect_output(summary(road_network), "Number of nodes")
  expect_output(summary(road_network), "Number of links")
})

test_that("`summary.road_network` works", {
  road_network <- create_road_network(sample_roads)

  # Check the summary function
  expect_output(summary(road_network), "Road network summary")
  expect_output(summary(road_network), "Number of nodes")
  expect_output(summary(road_network), "Number of links")
})

test_that("`plot.road_network` throw error with event mode and no events", {
  road_network <- create_road_network(sample_roads)

  # Check the plot function
  expect_error(plot(road_network, mode = "event"),
               "no events assigned to the road network")
})
