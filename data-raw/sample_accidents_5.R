sample_accidents_5 <- st_sf(
  id       = sprintf("ac5_%04x", 1:10),
  time     = c(1L, 5L, 10L, 14L, 17L, 19L, 21L, 23L, 2L, 6L),
  weather  = factor(
    c("Cloudy", "Sunny", "Rainy", "Snowy", "Sunny",
      "Rainy", "Sunny", "Foggy", "Cloudy", "Sunny"),
    levels = c("Sunny", "Cloudy", "Rainy", "Foggy", "Snowy")
  ),
  severity = factor(
    c("Minor", "Serious", "Minor", "Minor", "Serious",
      "Minor", "Fatal", "Minor", "Minor", "Serious"),
    levels = c("Minor", "Serious", "Fatal")
  ),
  geometry = pavement::create_points(
    1.4, 1.1, 2.8, 0.8, 3.5, 2.2, 4.9, 3.2, 5.5, 1.7,
    6.0, 2.9, 6.4, 1.6, 6.7, 1.1, 7.1, 2.9, 7.4, 3.4
  )
)
