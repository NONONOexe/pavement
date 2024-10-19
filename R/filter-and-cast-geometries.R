#' Filter and cast geometries
#'
#' This function filters a given geometries by specific type and casts
#' it to the specified type.
#'
#' @name filter_and_cast_geometries
#' @param geometries A `sf` object representing geometries.
#' @param geometry_type The type of geometry to filter and cast to.
#'   Must be one of "POINT", "LINESTRING", or "POLYGON".
#' @return A `sf` object containing only the specified type of geometry.
#' @export
#' @examples
#' plot(1, type = "n", xlab = "", ylab = "", axes = FALSE, xlim = c(0, 12), ylim = c(0, 10))
#' text(0, c(2, 6), c("Single", "Multiple"), srt = 90, cex = 1)
#' text(c(2, 6, 10), 8, c("Point", "Linestring", "Polygon"), cex = 1)
#'
#' geometries <- sf::st_sf(geometry = c(
#'   # POINT
#'   create_points(2, 2),
#'   # LINESTRING
#'   create_linestring(5, 1, 7, 3),
#'   # POLYGON
#'   create_polygon(9, 1, 9, 3, 11, 3, 11, 1),
#'   # MULTIPOINT
#'   sf::st_union(create_points(1, 7, 2, 6, 3, 5)),
#'   # MULTILINESTRING
#'   sf::st_union(
#'     create_linestring(5, 6, 6, 7),
#'     create_linestring(6, 5, 7, 6)
#'   ),
#'   # MULTIPOLYGON
#'   sf::st_union(
#'     create_polygon(9, 7, 10, 7, 10, 6, 9, 6),
#'     create_polygon(10, 5, 11, 6, 11, 5)
#'   )
#' ))
#' plot(geometries, pch = 16, lwd = 2, add = TRUE)
#'
#' # Get points from geometries
#' plot(get_points(geometries), pch = 16)
#'
#' # Get linestrings from geometries
#' plot(get_linestrings(geometries), lwd = 2)
#'
#' # Get polygons from geometries
#' plot(get_polygons(geometries), lwd = 2)
NULL

#' @rdname filter_and_cast_geometries
#' @export
filter_and_cast_geometries <- function(geometries,
                                       geometry_type = c("POINT", "LINESTRING", "POLYGON")) {
  # Validate the geometry type argument and select the appropriate type
  selected_type <- match.arg(geometry_type)
  multi_geometry_type <- paste0("MULTI", selected_type)

  # Filter the geometries based on the selected type and its MULTI version
  is_selected_geometry <- st_geometry_type(geometries) %in%
    c(selected_type, multi_geometry_type)
  filtered_geometries <- geometries[is_selected_geometry, ]

  # Cast the filtered geometries to the selected type
  decomposed_geometries <- st_cast(filtered_geometries, multi_geometry_type)
  casted_geometries <- st_cast(decomposed_geometries, selected_type)
  casted_geometries_with_crs <- st_set_crs(casted_geometries, st_crs(geometries))

  return(casted_geometries_with_crs)
}

#' @rdname filter_and_cast_geometries
#' @export
get_points <- function(geometries) {
  filter_and_cast_geometries(geometries, "POINT")
}

#' @rdname filter_and_cast_geometries
#' @export
get_linestrings <- function(geometries) {
  filter_and_cast_geometries(geometries, "LINESTRING")
}

#' @rdname filter_and_cast_geometries
#' @export
get_polygons <- function(geometries) {
  filter_and_cast_geometries(geometries, "POLYGON")
}
