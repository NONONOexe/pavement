#' Exclude points from a points object
#'
#' This function exclude points from a points object.
#'
#' @param points A `sfc` object containing points.
#' @param points_to_exclude A `sfc` object containing points to exclude.
#' @return A `sfc` object containing points with the excluded points removed.
#' @export
exclude_points <- function(points, points_to_exclude) {
  # Extract the geometry from the `points`
  points_geometry <- points$geometry
  # Extract the geometry from the `points_to_exclude`
  exclude_geometry <- st_cast(points_to_exclude$geometry, "POINT")

  # Check if each point in the `points` is equal
  # to any point in the `points_to_exclude`
  is_include <- as.logical(st_equals(points_geometry, exclude_geometry))

  # Filter the `points` to keep only the points
  # that are not in the `points_to_exclude`
  excluded_points <- points[is.na(is_include), ]

  return(excluded_points)
}
