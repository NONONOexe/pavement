#' Create points geometry
#'
#' This function creates a simple feature collection of points
#' from a series of x, y coordinates.
#'
#' @param ... A series of x, y coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system of the points.
#' @return A simple feature points object.
#' @examples
#' # Create a points from individual coordinates
#' points_1 <- create_points(0, 1, 1, 0, 2, 1)
#' points_1
#' plot(points_1)
#'
#' # Create a linestring from a numeric vector
#' points_2 <- create_points(
#'   c(0, 1, 1, 1, 1, 0, 0, 0, 0, 0.5, 1, 0.5)
#' )
#' points_2
#' plot(points_2)
create_points <- function(...) {
  UseMethod("create_points")
}

#' @export
create_points.numeric <- function(..., crs = NULL) {
  coordinates <- create_coordinates(...)
  if(is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_points.coordinates(coordinates, crs))
}

#' @export
create_points.coordinates <- function(coordinates, crs = NULL, ...) {
  points <- apply(coordinates, 1, st_point, simplify = FALSE)
  points <- st_sfc(points, crs = crs)

  return(points)
}
