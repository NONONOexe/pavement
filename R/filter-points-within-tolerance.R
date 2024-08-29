#' Filter geometries within a tolerance distance
#'
#' This function filters geometries that are within a specified tolerance
#' distance from a reference geometry.
#'
#' @param geometries A `sfc` object containing geometries to filter.
#' @param reference_geometry A single geometry object to use as a reference.
#' @param tolerance The maximum distance allowed between geometries and
#' the reference geometry. Geometries within this distance from
#' the reference geometry will be kept in the result.
#' @return A `sfc` object containing the filtered geometries.
#' @export
#' @examples
#' library(sf)
#'
#' # Create a points
#' points <- st_sfc(
#'   st_point(c(0.000, 0.000)),
#'   st_point(c(1.000, 0.100)),
#'   st_point(c(2.000, 0.010)),
#'   st_point(c(4.000, 0.001)),
#'   st_point(c(5.001, 0.000)),
#'   st_point(c(6.000, 0.000))
#' )
#'
#' # Create a linestring (reference geometry)
#' linestring <- create_linestring(0, 0, 5, 0)
#'
#' # Plot the points
#' plot(linestring, col = "gray")
#' plot(points, add = TRUE)
#'
#' # Filter points within a tolerance distance (default: 0.01)
#' filtered_points <- filter_geometries_within_tolerance(points, linestring)
#'
#' # Plot the filtered points
#' plot(linestring, col = "gray")
#' plot(filtered_points, add = TRUE)
filter_geometries_within_tolerance <- function(geometries,
                                               reference_geometry,
                                               tolerance = 0.01) {
  # Calculate the distance between the geometries and the reference geometry
  distance_to_geometries <- st_distance(reference_geometry, geometries)[1, ]

  # Filter geometries that are within the tolerance distance
  filtered_geometries <- geometries[distance_to_geometries <= tolerance]

  return(filtered_geometries)
}
