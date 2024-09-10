test_that("`compute_epanechnikov` works for a vector of valid input", {
  x <- seq(-1.5, 1.5, 0.5)
  results <- compute_epanechnikov(x)
  expect_equal(results, c(0, 0, 9/16, 3/4, 9/16, 0, 0))
})
