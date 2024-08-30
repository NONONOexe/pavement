#' Filter points within a tolerance distance
#'
#' This function filters points that are within a specified tolerance
#' distance from a reference linestring.
#'
#' @param points A `sfc` object containing points to filter.
#' @param linestring A linestring object.
#' @param tolerance A numeric value representing the maximum allowable
#'   distance between points and the linestring. Points within this
#'   distance from the linestring will be included in the filtered set.
#' @return A `sfc` object containing the filtered points.
#' @export
#' @examples
#' library(sf)
#'
#' # Create a points
#' points <- st_sfc(
#'   st_point(c(0.000, 1.000)),
#'   st_point(c(0.500, 0.600)),
#'   st_point(c(1.000, 0.010)),
#'   st_point(c(1.500, 0.501)),
#'   st_point(c(2.000, 0.990))
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
#' filtered_points <- filter_points_within_tolerance(points, linestring)
#'
#' # Plot the filtered points
#' plot(linestring, col = "gray")
#' plot(filtered_points, add = TRUE)
filter_points_within_tolerance <- function(points,
                                           linestring,
                                           tolerance = 0.01) {
  # Calculate the distance between the points and the linestring
  linestring_sfc <- st_sfc(linestring, crs = st_crs(points))
  distances_to_linestring <- as.vector(st_distance(points, linestring_sfc))

  # Filter points that are within the tolerance distance
  filtered_points <- points[distances_to_linestring <= tolerance]

  return(filtered_points)
}
