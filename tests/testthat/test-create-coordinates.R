test_that(
  paste("`create_coordinates()` returns a `coordinates` object with the",
        "correct dimensions when given a sequence of x and y coordinates"),
  {
    expect_equal(
      create_coordinates(1, 2, 3, 4),
      structure(
        matrix(c(1, 2, 3, 4), ncol = 2, byrow = TRUE),
        class = "coordinates")
    )
  }
)

test_that(
  paste("`create_coordinates()` returns a `coordinates` object with the ",
        "correct dimensions when given a vector of x and y coordinates"),
  {
    expect_equal(
      create_coordinates(c(1, 2, 3, 4)),
      structure(
        matrix(c(1, 2, 3, 4), ncol = 2, byrow = TRUE),
        class = "coordinates"
      )
    )
  }
)

test_that(
  paste("`create_coordinates()` returns an empty `coordinates` object when",
        "no arguments are provided"),
  {
    expect_equal(
      create_coordinates(),
      structure(
        matrix(double(), ncol = 2, byrow = TRUE),
        class = "coordinates"
      )
    )
  }
)

test_that(
  paste("`create_coordinates()` throws an error when an odd number of",
        "arguments are provided"),
  {
    expect_error(
      create_coordinates(1, 2, 3),
      "arguments must be provided in pairs \\(x, y\\) coordinates"
    )
  }
)

test_that(
  paste("print.coordinates() prints a coordinates object in the correct",
        "format"),
  {
    coordinates <- create_coordinates(1, 2, 3, 4)
    expect_output(print(coordinates), "\\{\\(1, 2\\), \\(3, 4\\)\\}")
  }
)

test_that(
  paste("print.coordinates() prints an empty coordinates object correctly"), {
    coordinates <- create_coordinates()
    expect_output(print(coordinates), "\\{\\}")
  }
)
