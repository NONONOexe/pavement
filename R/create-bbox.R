#' Create a bounding box
#'
#' This function creates a bounding box from either cardinal coordinates
#' (north, south, east and west) or center coordinates and dimensions
#' (center longitude and latitude, and size of width and height).
#'
#' @param north The northernmost latitude.
#' @param south The southernmost latitude.
#' @param east The easternmost longitude.
#' @param west The westernmost longitude.
#' @param center_lon The center longitude.
#' @param center_lat The center latitude.
#' @param width The width of the bounding box.
#' @param height The height of the bounding box.
#' @return A 2x2 matrix representing the bounding box.
#' @export
#' @examples
#' # Create a bounding box from cardinal coordinates
#' create_bbox(
#'   north =  35.1899,
#'   south =  35.1399,
#'   east  = 136.9524,
#'   west  = 136.8524
#' )
#'
#' # Create a bounding box from center coordinates and dimensions
#' create_bbox(
#'   center_lon = 136.9024,
#'   center_lat =  35.1649,
#'   width      = 0.10,
#'   height     = 0.05
#' )
create_bbox <- function(north = NULL, south = NULL,
                        east = NULL, west = NULL,
                        center_lon = NULL, center_lat = NULL,
                        width = NULL, height = NULL) {
  if (!is.null(north) && !is.null(south) && !is.null(east) && !is.null(west)) {
    validate_cardinal_points(north, south, east, west)
  } else if (!is.null(center_lon) && !is.null(center_lat) &&
             !is.null(width) && !is.null(height)) {
    validate_dimensions(width, height)
    west <- center_lon - width / 2
    east <- center_lon + width / 2
    south <- center_lat - height / 2
    north <- center_lat + height / 2
  } else {
    stop("invalid argument provided")
  }

  bbox <- matrix(c(west, south, east, north), nrow = 2)
  dimnames(bbox) <- list(c("x", "y"), c("min", "max"))
  return(bbox)
}

validate_cardinal_points <- function(north, south, east, west) {
  if (north <= south) stop("`north` must be greater than `south`")
  if (east <= west) stop("`east` must be greater than `west`")
}

validate_dimensions <- function(width, height) {
  if (width <= 0 || height <= 0) stop("`width` and `height` must be positive")
}


#' Create a bounding box from center coordinates and distance in km
#'
#' @description
#' Calculates a rectangular bounding box based on a central coordinate and
#' physical dimensions in kilometers. Uses a Cartesian (UTM) projection to
#' compute offsets and returns the bounding box in WGS84 as a 2x2 matrix.
#'
#' @param center_lon Center longitude (degrees)
#' @param center_lat Center latitude (degrees)
#' @param width_km Width of the rectangle in km (East-West)
#' @param height_km Height of the rectangle in km (North-South)
#' @return A 2x2 matrix representing the bounding box
#' @examples
#' # Create a 6.5 km × 4.5 km bounding box centered around Nagoya
#' bbox <- create_bbox_km_cartesian(
#'   center_lon = 136.9,
#'   center_lat = 35.17,
#'   width_km   = 6.5,
#'   height_km  = 4.5
#' )
#' @export
create_bbox_km_cartesian <- function(center_lon, center_lat, width_km, height_km) {

  if (any(sapply(list(center_lon, center_lat, width_km, height_km), is.null))) {
    stop("All arguments must be provided")
  }
  if (width_km <= 0 || height_km <= 0) stop("width_km and height_km must be positive")

  utm_zone <- floor((center_lon + 180) / 6) + 1
  utm_epsg <- 32600 + utm_zone

  center_wgs84 <- sf::st_sfc(sf::st_point(c(center_lon, center_lat)), crs = 4326)
  center_utm <- sf::st_transform(center_wgs84, crs = utm_epsg)

  coords <- sf::st_coordinates(center_utm)
  x0 <- coords[1]
  y0 <- coords[2]

  dx <- width_km * 1000 / 2
  dy <- height_km * 1000 / 2

  west_utm  <- x0 - dx
  east_utm  <- x0 + dx
  south_utm <- y0 - dy
  north_utm <- y0 + dy

  corners_utm <- sf::st_sfc(
    sf::st_point(c(west_utm, south_utm)),
    sf::st_point(c(east_utm, north_utm)),
    crs = utm_epsg
  )
  corners_wgs84 <- sf::st_transform(corners_utm, 4326)
  corner_coords <- sf::st_coordinates(corners_wgs84)

  west  <- corner_coords[1,1]
  south <- corner_coords[1,2]
  east  <- corner_coords[2,1]
  north <- corner_coords[2,2]

  bbox <- matrix(c(west, south, east, north), nrow = 2)
  dimnames(bbox) <- list(c("x","y"), c("min","max"))

  return(bbox)
}
