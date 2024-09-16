test_that("`create_spatiotemporal_event` works with valid input", {
  spatiotemporal_events <- create_spatiotemporal_event(sample_accidents)

  expect_s3_class(spatiotemporal_events, "spatiotemporal_event")
  expect_equal(attr(spatiotemporal_events, "time_column"), "time")
  expect_equal(attr(spatiotemporal_events, "time_format"), "%H")
})

test_that("`print.spatiotemporal_event` prints the correct information", {
  spatiotemporal_events <- create_spatiotemporal_event(sample_accidents)
  output <- capture.output(print(spatiotemporal_events))

  expect_equal(output[1],
               "Spatiotemporal event collection with 10 events and 3 fields")
  expect_equal(output[2], "Geometry type: POINT")
  expect_equal(output[3], "Time column:   time")
  expect_equal(output[4], "Time format:   %H")
  expect_equal(output[5], "Data:")
  expect_equal(output[7], "1 ac_0001   18   Sunny    Minor     POINT (1 1)")
  expect_equal(output[11], "5 ac_0005    7   Rainy    Minor POINT (5.9 1.1)")
  expect_equal(output[12], "... 5 more events")
})
