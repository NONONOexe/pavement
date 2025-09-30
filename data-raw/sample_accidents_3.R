sample_accidents_3 <- st_sf(
  id       = sprintf("ac3_%04x", 1:10),
  time     = c(0L, 8L, 13L, 17L, 19L, 21L, 23L, 3L, 6L, 9L),
  weather  = factor(
    c("Rainy", "Sunny", "Cloudy", "Foggy", "Sunny",
      "Rainy", "Sunny", "Snowy", "Sunny", "Cloudy"),
    levels = c("Sunny", "Cloudy", "Rainy", "Foggy", "Snowy")
  ),
  severity = factor(
    c("Minor", "Fatal", "Minor", "Serious", "Minor",
      "Minor", "Fatal", "Minor", "Serious", "Minor"),
    levels = c("Minor", "Serious", "Fatal")
  ),
  geometry = pavement::create_points(
    1.1, 1.3, 2.6, 0.5, 3.2, 2.3, 4.6, 2.9, 5.6, 1.8,
    5.7, 2.9, 6.1, 1.5, 6.5, 1.0, 6.9, 2.6, 7.2, 3.0
  )
)
