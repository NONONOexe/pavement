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
#' create_bbox(c(
#'   north =  35.1899,
#'   south =  35.1399,
#'   east  = 136.9524,
#'   west  = 136.8524
#' ))
#'
#' # Create a bounding box from center coordinates and dimensions
#' create_bbox(c(
#'   center_lon = 136.9024,
#'   center_lat =  35.1649,
#'   width      = 0.10,
#'   height     = 0.05)
#' )
create_bbox <- function(x) {
  # Check if the input is numeric
  if (!is.numeric(x)) {
    stop("`x` must be numeric")
  }

  # Create bounding box from cardinal coordinates
  if (all(c("north", "south", "east", "west") %in% names(x))) {
    return(create_bbox_from_cardinal_points(x))
  }

  # Create bounding box from center coordinates and dimensions
  if (all(c("center_lon", "center_lat", "width", "height") %in% names(x))){
    return(create_bbox_from_center(x))
  }

  # Stop execution if invalid argument is provided
  stop("Invalid argument provided")
}

# Create a bounding box from cardinal coordinates (north, south, east and west)
create_bbox_from_cardinal_points <- function(x) {
  if (x["north"] <= x["south"])
      stop("`north` must be greater than `south`")

  if (x["east"] <= x["west"])
    stop("`east` must be greater than `west`")

  data <- c(x["west"], x["south"], x["east"], x["north"])
  bbox <- matrix(data, nrow = 2)
  dimnames(bbox) <- list(c("x", "y"), c("min", "max"))

  return(bbox)
}

# Create a bounding box from center coordinates (center longitude and latitude)
# and dimensions (size of width and height)
create_bbox_from_center <- function(x) {
  if (x["width"] <= 0)
    stop("`width` must be positive")

  if (x["height"] <= 0)
    stop("`height` must be positive")

  min_lon <- x["center_lon"] - x["width"] / 2
  max_lon <- x["center_lon"] + x["width"] / 2
  min_lat <- x["center_lat"] - x["height"] / 2
  max_lat <- x["center_lat"] + x["height"] / 2

  data <- c(min_lon, min_lat, max_lon, max_lat)
  bbox <- matrix(data, nrow = 2)
  dimnames(bbox) <- list(c("x", "y"), c("min", "max"))

  return(bbox)
}
