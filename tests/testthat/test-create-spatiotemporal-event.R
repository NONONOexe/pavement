test_that("`create_spatiotemporal_event` works with valid input", {
  spatiotemporal_events <- create_spatiotemporal_event(sample_accidents)

  # Check the structure of the spatiotemporal events
  expect_s3_class(spatiotemporal_events, "spatiotemporal_event")
  expect_equal(attr(spatiotemporal_events, "time_column"), "time")
  expect_equal(attr(spatiotemporal_events, "time_format"), "%H")
})

test_that("`print.spatiotemporal_event` prints the correct information", {
  spatiotemporal_events <- create_spatiotemporal_event(sample_accidents)

  # Check the print function
  expect_output(print(spatiotemporal_events),
                "Spatiotemporal event collection with 10 events and 3 fields")
  expect_output(print(spatiotemporal_events), "Geometry type: POINT")
  expect_output(print(spatiotemporal_events), "Time column:   time")
  expect_output(print(spatiotemporal_events), "Time format:   %H")
  expect_output(print(spatiotemporal_events), "Data:")
  expect_output(print(spatiotemporal_events), "\\.\\.\\. 5 more events")
})
