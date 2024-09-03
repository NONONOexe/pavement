test_that("`create_bbox` works with valid cardinal coordinates", {
  north <-  35.17377
  south <-  35.16377
  east  <- 136.91590
  west  <- 136.90090

  bbox <- create_bbox(north = north, south = south, east = east, west = west)

  expect_true(is.matrix(bbox))
  expect_equal(dim(bbox), c(2, 2))
  expect_equal(bbox[1, "min"], west)
  expect_equal(bbox[1, "max"], east)
  expect_equal(bbox[2, "min"], south)
  expect_equal(bbox[2, "max"], north)
})

test_that("`create_bbox` works with valid center coordinates and dimensions", {
  center_lon <- 136.9024
  center_lat <-  35.1649
  width  <- 0.10
  height <- 0.05

  bbox <- create_bbox(center_lon = center_lon, center_lat = center_lat,
                      width = width, height = height)

  expect_true(is.matrix(bbox))
  expect_equal(dim(bbox), c(2, 2))
  expect_equal(bbox[1, "min"], center_lon - width / 2)
  expect_equal(bbox[1, "max"], center_lon + width / 2)
  expect_equal(bbox[2, "min"], center_lat - height / 2)
  expect_equal(bbox[2, "max"], center_lat + height / 2)
})

test_that("`create_bbox` throws an error with invalid `north` and `south`", {
  north <-  0
  south <- 10
  east  <-  5
  west  <- -5

  expect_error(
    create_bbox(north = north, south = south, east = east, west = west),
    "`north` must be greater than `south`"
  )
})

test_that("`create_bbox` throws an error with invalid `east` and `west`", {
  north <- 10
  south <-  0
  east  <- -5
  west  <-  5

  expect_error(
    create_bbox(north = north, south = south, east = east, west = west),
    "`east` must be greater than `west`"
  )
})

test_that("`create_bbox` throws an error with invalid dimensions", {
  center_lon <-  0
  center_lat <- 10
  width  <- -10
  height <-   5

  expect_error(
    create_bbox(center_lon = center_lon, center_lat = center_lat,
                width = width, height = height),
    "`width` and `height` must be positive"
  )
})

test_that("`create_bbox` throws an error with invalid arguments", {
  expect_error(create_bbox(), "invalid argument provided")
})
