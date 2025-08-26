sample_accidents_2 <- st_sf(
  id       = sprintf("ac2_%04x", 1:10),
  time     = c(5L, 11L, 14L, 16L, 20L, 22L, 1L, 3L, 7L, 10L),
  weather  = factor(
    c("Cloudy", "Sunny", "Rainy", "Sunny", "Snowy",
      "Foggy", "Rainy", "Sunny", "Cloudy", "Sunny"),
    levels = c("Sunny", "Cloudy", "Rainy", "Foggy", "Snowy")
  ),
  severity = factor(
    c("Serious", "Minor", "Minor", "Fatal", "Minor",
      "Serious", "Minor", "Minor", "Fatal", "Minor"),
    levels = c("Minor", "Serious", "Fatal")
  ),
  geometry = pavement::create_points(
    1.2, 1.1, 2.5, 0.6, 3.0, 2.5, 4.5, 3.0, 5.4, 1.6,
    5.9, 2.7, 6.2, 1.3, 6.4, 0.9, 6.8, 2.5, 7.1, 3.2
  )
)

