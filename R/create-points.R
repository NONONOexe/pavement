#' Create points geometry
#'
#' This function creates a simple feature collection of points
#' from a series of x, y coordinates.
#'
#' @name create_points
#' @param ... A series of x, y coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system.
#' @return A simple feature points object.
#' @export
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
NULL

#' @rdname create_points
#' @export
create_points <- function(...) {
  UseMethod("create_points")
}

#' @rdname create_points
#' @export
create_points.numeric <- function(..., crs = NULL) {
  coordinates <- create_coordinates(...)
  if(is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_points.coordinates(coordinates, crs))
}

#' @rdname create_points
#' @export
create_points.coordinates <- function(coordinates, crs = NULL, ...) {
  points <- apply(coordinates, 1, sf::st_point, simplify = FALSE)
  points_sfc <- sf::st_sfc(points, crs = crs)

  return(points_sfc)
}
