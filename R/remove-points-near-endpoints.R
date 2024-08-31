#' Remove points near endpoints of a linestring
#'
#' This function removes points from a set of points that are within a
#' specified tolerance distance of the start or end point of a linestring.
#'
#' @param points A `sfc` object containing points to filter.
#' @param linestring A linestring object.
#' @param tolerance A numeric value representing the maximum distance
#'   from the line's ends to consider points for filtering. Points within
#'   this distance will be excluded.
#' @return A `sfc` object containing the filtered points.
#' @export
#' @examples
#' # Create a points
#' points <- create_points(
#'   0.000, 1.000, 0.500, 0.600, 1.000, 0.010, 1.500, 0.501, 2.000, 0.990
#' )
#'
#' # Create a linestring
#' linestring <- create_linestring(0, 1, 1, 0, 2, 1)
#'
#' # Plot the points
#' plot(linestring, col = "gray")
#' plot(points, add = TRUE)
#'
#' # Filter points within a tolerance distance (default: 0.01)
#' filtered_points <- remove_points_near_endpoints(points, linestring)
#'
#' # Plot the filtered points
#' plot(linestring, col = "gray")
#' plot(filtered_points, add = TRUE)
remove_points_near_endpoints <- function(points,
                                         linestring,
                                         tolerance = 0.01) {
  # Get the start and end points of the linestring
  linestring_sfc <- st_sfc(linestring, crs = st_crs(points))
  start_point <- st_startpoint(linestring_sfc)
  end_point <- st_endpoint(linestring_sfc)

  # Filter points based on distance from start and end points
  filtered_points <- points[
    (tolerance < as.vector(st_distance(start_point, points))) &
      (tolerance < as.vector(st_distance(end_point, points)))
  ]

  return(filtered_points)
}
