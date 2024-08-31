#' Create a simple feature collection of points
#'
#' This function creates a simple feature collection of points
#' from a series of x, y coordinates.
#'
#' @param ... A series of x, y coordinates.
#' @param crs The coordinate reference system of the points.
#' @return A simple feature collection of points.
#' @export
#' @examples
#' # Create points
#' points <- create_points(0, 1, 1, 0, 2, 1)
#' points
#'
#' # Plot the points
#' plot(points)
create_points <- function(..., crs = "NA") {
  # Unlist the arguments to a vector
  points <- unlist(list(...))

  # If no arguments are provided, return an empty collection of points
  if (length(points) == 0) {
    return(st_sfc(st_point(), crs = crs))
  }

  # Check if the number of arguments is even
  if (length(points) %% 2 != 0) {
    stop("arguments must be provided in pairs (x, y) coordinates")
  }

  # Create a simple feature collection of points
  points_mat <- matrix(points, ncol = 2, byrow = TRUE)
  points_sfg <- apply(points_mat, 1, st_point, simplify = FALSE)
  points <- st_sfc(points_sfg, crs = crs)

  return(points)
}
