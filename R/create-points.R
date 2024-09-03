#' Create a simple feature collection of points
#'
#' This function creates a simple feature collection of points
#' from a series of x, y coordinates.
#'
#' @name create_points
#' @param ... A series of x, y coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system of the points.
#' @return A simple feature points object.
#' @examples
#' # Create points
#' points <- create_points(0, 1, 1, 0, 2, 1)
#'
#' # Plot the points
#' plot(points)
NULL

#' @export
create_points <- function(...) {
  UseMethod("create_points")
}

#'@export
create_points.numeric <- function(..., crs = NULL) {
  coordinates <- create_coordinates(...)
  crs <- ifelse(is.null(crs), "NA", crs)

  return(create_points.coordinates(coordinates, crs))
}

#'@export
create_points.coordinates <- function(coordinates, crs = NULL, ...) {
  points <- apply(coordinates, 1, st_point, simplify = FALSE)
  points <- st_sfc(points, crs = crs)

  return(points)
}
