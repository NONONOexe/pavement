test_that("`create_segmented_network` works with valid input", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network)

  # The returned object has the correct class
  expect_s3_class(segmented_network, "segmented_network")

  # The specified segment length is correctly stored
  expect_equal(segmented_network$segment_length, 1)

  # The number of split segments is greater than the number of original links
  expect_gt(nrow(segmented_network$segments), nrow(road_network$links))

  # Each segment length is approximately equal to the specified segment length
  expect_true(all(abs(sf::st_length(segmented_network$segments) - 1) < 0.1))
})

test_that("`create_segmented_network` works with events", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network,
                                                events = sample_accidents)

  expect_s3_class(segmented_network, "segmented_network")
  expect_equal(segmented_network$segment_length, 1)
  expect_equal(nrow(segmented_network$events), 10)
})

test_that("`create_segmented_network` handles events in the original network", {
  road_network <- create_road_network(sample_roads, events = sample_accidents)
  segmented_network <- create_segmented_network(road_network)

  expect_s3_class(segmented_network, "segmented_network")
  expect_equal(segmented_network$segment_length, 1)
  expect_equal(nrow(segmented_network$events), 10)
})

test_that("`create_segmented_network` warns if events already exist", {
  road_network <- create_road_network(sample_roads, events = sample_accidents)
  expect_warning(create_segmented_network(road_network,
                                          events = sample_accidents),
                 "events already exist in the road network")
})

test_that("`print.segmented_network` works", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network)

  expect_output(print(segmented_network), "Segmented network")
  expect_output(print(segmented_network), "Segment length")
  expect_output(print(segmented_network), "Segments")
})

test_that("`summary.segmented_network` works", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network)

  expect_output(summary(segmented_network), "Segmented network summary")
  expect_output(summary(segmented_network), "Segment length")
  expect_output(summary(segmented_network), "Number of segments")
})

test_that("`plot.segmented_network` works with default modes", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network)

  expect_silent(plot(segmented_network))
})

test_that("`plot.segmented_network` works with event modes", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network,
                                                events = sample_accidents)

  expect_silent(plot(segmented_network, mode = "event"))
})

test_that("`plot.segmented_network` works with count modes", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network,
                                                events = sample_accidents)

  expect_silent(plot(segmented_network, mode = "count"))
})

test_that("`plot.segmented_network` works with count modes", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network,
                                                events = sample_accidents)

  expect_silent(plot(segmented_network, mode = "count"))
})

test_that("`plot.segmented_network` works with density modes", {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network,
                                                events = sample_accidents)
  segmented_network <- convolute_segmented_network(segmented_network)

  expect_silent(plot(segmented_network, mode = "density"))
})

test_that(paste("`plot.segmented_network` throws error when event mode is",
                "used but no events are assigned"), {
  road_network <- create_road_network(sample_roads)
  segmented_network <- create_segmented_network(road_network)

  expect_error(plot(segmented_network, mode = "event"),
               "no events assigned to the road network")
})
