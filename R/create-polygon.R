#' Create a polygon geometry
#'
#' This function creates a polygon from a bounding box or a series of
#' x, y coordinates.
#'
#' @name create_polygon
#' @param ... A series of x, y coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system.
#' @return A polygon object.
#' @export
#' @examples
#' polygon <- create_polygon(
#'   136.9009, 35.16377,
#'   136.9159, 35.16377,
#'   136.9159, 35.17377,
#'   136.9009, 35.17377,
#'   crs = 4326
#' )
create_polygon <- function(...) {
  UseMethod("create_polygon")
}

#' @rdname create_polygon
#' @export
create_polygon.numeric <- function(..., crs = NULL) {
  coordinates <- create_coordinates(...)
  if(is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_polygon.coordinates(coordinates, crs))
}

#' @rdname create_polygon
#' @export
create_polygon.coordinates <- function(coordinates, crs = NULL, ...) {
  is_closed <- all(coordinates[1, ] == coordinates[nrow(coordinates), ])
  closed_path <- if (is_closed) {
    coordinates
  } else {
    create_coordinates(c(t(coordinates), coordinates[1, ]))
  }
  polygon <- sf::st_polygon(list(closed_path))
  polygon_sfc <- sf::st_sfc(polygon, crs = crs)

  return(polygon_sfc)
}
