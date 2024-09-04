#' Create a linestring geometry
#'
#' This function creates a simple feature linestring object
#' from a series of x, y coordinates.
#'
#' @name create_linestring
#' @param ... A series of x, y coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system of the points.
#' @return A simple feature linestring object.
#' @examples
#' # Create a linestring from individual coordinates
#' linestring_1 <- create_linestring(0, 1, 1, 0, 2, 1)
#' linestring_1
#' plot(linestring_1)
#'
#' # Create a linestring from a numeric vector
#' linestring_2 <- create_linestring(
#'   c(0, 1, 1, 1, 1, 0, 0, 0, 0, 0.5, 1, 0.5)
#' )
#' linestring_2
#' plot(linestring_2)
NULL

#' @rdname create_linestring
#' @export
create_linestring <- function(...) {
  UseMethod("create_linestring")
}

#' @rdname create_linestring
#' @export
create_linestring.numeric <- function(..., crs = NULL) {
  coordinates <- create_coordinates(...)
  if(is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_linestring.coordinates(coordinates, crs))
}

#' @rdname create_linestring
#' @export
create_linestring.coordinates <- function(coordinates, crs = NULL, ...) {
  linestring <- st_linestring(coordinates)
  linestring <- st_sfc(linestring, crs = crs)

  return(linestring)
}
