# ---- Year 1 ----
acc1 <- st_sf(
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
  ),
  year = 1L
)

# ---- Year 2 ----
acc2 <- st_sf(
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
  ),
  year = 2L
)

# ---- Year 3 ----
acc3 <- st_sf(
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
  ),
  year = 3L
)

# ---- Year 4 ----
acc4 <- st_sf(
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
  ),
  year = 4L
)

# ---- Year 5 ----
acc5 <- st_sf(
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
  ),
  year = 5L
)

# Combine all
sample_accidents_multiyear <- rbind(acc1, acc2, acc3, acc4, acc5)
