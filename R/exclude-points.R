#' Exclude points from a points
#'
#' This function excludes points from a points.
#'
#' @param input_points A `sfc` object containing points.
#' @param points_to_exclude A `sfc` object containing points to exclude.
#' @return A `sfc` object containing the points from `input_points` that are
#'   not in `points_to_exclude`.
#' @export
#' @examples
#' # Create a set of points and a set of points to exclude
#' points <- create_points(0, 0, 1, 0, 0, 1, 1, 1)
#' points_to_exclude <- create_points(0, 0, 1, 1)
#' plot(points)
#' plot(points_to_exclude, add = TRUE, pch = 4)
#'
#' # Exclude points in `points_to_exclude` from `points`
#' remain_points <- exclude_points(points, points_to_exclude)
#' plot(remain_points)
exclude_points <- function(input_points, points_to_exclude) {
  # Check if each point in `input_points` is equal to any point
  # in `points_to_exclude`
  point_match <- st_equals(input_points, points_to_exclude)

  # Identify points that are not in `points_to_exclude`
  is_point_to_keep <- sapply(point_match, length) == 0

  # Subset `input_points` to keep only points that are not
  # in `points_to_exclude`
  remain_points <- input_points[is_point_to_keep, ]

  return(remain_points)
}
