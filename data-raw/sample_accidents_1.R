sample_accidents_1 <- st_sf(
  id       = sprintf("ac1_%04x", 1:10),
  time     = c(6L, 9L, 12L, 15L, 18L, 21L, 23L, 2L, 4L, 8L),
  weather  = factor(
    c("Sunny", "Cloudy", "Rainy", "Foggy", "Sunny",
      "Rainy", "Sunny", "Snowy", "Sunny", "Cloudy"),
    levels = c("Sunny", "Cloudy", "Rainy", "Foggy", "Snowy")
  ),
  severity = factor(
    c("Minor", "Minor", "Serious", "Minor", "Fatal",
      "Minor", "Serious", "Minor", "Minor", "Fatal"),
    levels = c("Minor", "Serious", "Fatal")
  ),
  geometry = pavement::create_points(
    1.0, 1.0, 2.2, 0.4, 3.1, 2.1, 4.7, 2.8, 5.2, 1.4,
    5.8, 2.5, 6.0, 1.2, 6.3, 0.8, 6.7, 2.4, 7.0, 2.9
  )
)


