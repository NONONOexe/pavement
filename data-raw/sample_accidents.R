sample_accidents <- sf::st_sf(
  id       = sprintf("ac_%04x", 1:10),
  time     = c(18L, 4L, 13L, 23L, 7L, 7L, 19L, 8L, 19L, 20L),
  weather  = factor(
    c(
      "Sunny", "Foggy", "Snowy", "Sunny", "Rainy",
      "Sunny", "Cloudy", "Sunny", "Rainy", "Sunny"
    ),
    levels = c("Sunny", "Cloudy", "Rainy", "Foggy", "Snowy")
  ),
  severity = factor(
    c(
      "Minor", "Fatal", "Minor", "Minor", "Minor",
      "Minor", "Minor", "Minor", "Serious", "Minor"
    ),
    levels = c("Minor", "Serious", "Fatal")
  ),
  geometry = pavement::create_points(
    1.0, 1.0, 3.2, 0.4, 4.1, 3.1, 5.7, 3.1, 5.9, 1.1,
    6.0, 3.0, 6.1, 0.9, 6.1, 1.2, 6.2, 2.9, 6.5, 3.0
  )
)
