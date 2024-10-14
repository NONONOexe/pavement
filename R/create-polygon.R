#' Create a polygon geometry
#'
#' This function creates a polygon from a bounding box or a series of
#' x, y coordinates.
#'
#' @name create_polygon
#' @param ... Arguments passed to methods.
#' @param bbox A numeric matrix with two columns and two rows.
#'   `bbox` represents the minimum and maximum coordinates.
#' @param coordinates A `coordinates` object.
#' @param crs The coordinate reference system.
#' @return A polygon object.
#' @export
#' @examples
#' bbox <- create_bbox(center_lon = 136.9024,
#'                     center_lat =  35.1649,
#'                     width      = 0.10,
#'                     height     = 0.05)
#' bbox_sfc <- create_polygon(bbox, crs = 4326)
create_polygon <- function(...) {
  UseMethod("create_polygon")
}

#' @rdname create_polygon
#' @export
create_polygon.matrix <- function(bbox, crs = NULL, ...) {
  tl <- bbox[,1]
  br <- bbox[,2]
  tr <- c(tl[1], br[2])
  bl <- c(br[1], tl[2])
  coordinates <- create_coordinates(tl, bl, br, tr, tl)
  if (is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_polygon.coordinates(coordinates, crs))
}

#' @rdname create_polygon
#' @export
create_polygon.coordinates <- function(coordinates, crs = NULL, ...) {
  polygon <- st_polygon(list(coordinates))
  polygon <- st_sfc(polygon, crs = crs)

  return(polygon)
}
