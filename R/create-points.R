#' Create points geometry
#'
#' This function creates a simple feature collection of points
#' from a series of x, y coordinates.
#'
#' @name create_points
#' @param ... A series of x, y coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system.
#' @param as_multipoint Logical; if `TRUE`, create a single `MULTIPOINT`
#'   geometry instead of multiple `POINT` geometries.
#' @return A simple feature geometry list column (`sfc`).
#' @export
#' @examples
#' # Create multiple points from individual coordinates
#' points <- create_points(0, 0, 0, 2, 2, 2, 2, 1, 0, 1)
#' points
#' plot(points)
#'
#' # Create points from a numeric vector
#' create_points(c(0, 0, 0, 2, 2, 2, 2, 1, 0, 1))
#'
#' # Create a `MULTIPOINT` instead of separate `POINT`s
#' create_points(0, 0, 0, 2, 2, 2, 2, 1, 0, 1, as_multipoint = TRUE)
NULL

#' @rdname create_points
#' @export
create_points <- function(...) {
  UseMethod("create_points")
}

#' @rdname create_points
#' @export
create_points.numeric <- function(..., crs = NULL, as_multipoint = FALSE) {
  coordinates <- create_coordinates(...)
  if(is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_points.coordinates(coordinates,
                                   crs           = crs,
                                   as_multipoint = as_multipoint))
}

#' @rdname create_points
#' @export
create_points.coordinates <- function(coordinates,
                                      crs           = NULL,
                                      as_multipoint = FALSE,
                                      ...) {
  points <- apply(coordinates, 1, sf::st_point, simplify = FALSE)
  points_sfc <- sf::st_sfc(points, crs = crs)

  if (as_multipoint) {
    return(sf::st_union(points_sfc))
  } else {
    return(points_sfc)
  }
}
