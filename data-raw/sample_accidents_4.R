sample_accidents_4 <- st_sf(
  id       = sprintf("ac4_%04x", 1:10),
  time     = c(2L, 7L, 11L, 15L, 18L, 20L, 22L, 1L, 4L, 12L),
  weather  = factor(
    c("Sunny", "Snowy", "Cloudy", "Sunny", "Foggy",
      "Rainy", "Sunny", "Cloudy", "Sunny", "Rainy"),
    levels = c("Sunny", "Cloudy", "Rainy", "Foggy", "Snowy")
  ),
  severity = factor(
    c("Minor", "Minor", "Serious", "Minor", "Minor",
      "Serious", "Fatal", "Minor", "Fatal", "Minor"),
    levels = c("Minor", "Serious", "Fatal")
  ),
  geometry = pavement::create_points(
    1.3, 1.2, 2.7, 0.7, 3.4, 2.0, 4.8, 3.1, 5.3, 1.5,
    5.8, 2.8, 6.3, 1.4, 6.6, 0.7, 7.0, 2.8, 7.3, 3.3
  )
)
