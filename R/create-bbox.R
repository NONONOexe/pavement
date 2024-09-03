#' Create a bounding box
#'
#' This function creates a bounding box from either cardinal coordinates
#' (north, south, east and west) or center coordinates and dimensions
#' (center longitude and latitude, and size of width and height).
#'
#' @param x A named vector containing the bounding box coordinates.
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
