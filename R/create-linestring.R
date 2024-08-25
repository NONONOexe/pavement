#' Create a linestring geometry
#'
#' This function takes a series of numeric arguments representing x and y
#' coordinates and creates a linestring geometry object.
#'
#' @param x A numeric vector, or the first x coordinate.
#' @param ... Additional numeric vectors.
#' @return A `sf` linestring object.
#' @export
#' @examples
#' # Create a linestring from individual coordinates
#' create_linestring(0, 0, 3, 0, 4, 3)
#'
#' # Create a linestring from a numeric vector
#' create_linestring(c(0, 0, 3, 0, 4, 3))
create_linestring <- function(x = NULL, ...) {
  # Collect all arguments
  arguments <- if (missing(...)) as.list(x) else list(x, ...)

  # If no arguments are provided, create an empty linestring
  if (length(arguments) == 0) {
    return(st_linestring())
  }

  # Check if all arguments are numeric
  if (!all(sapply(arguments, is.numeric))) {
    stop("all arguments must be numeric")
  }
  # Check if the number of arguments is even
  if (length(arguments) %% 2 != 0) {
    stop("arguments must be provided in pairs (x, y) coordinates")
  }

  # Create a matrix of coordinates
  coordinates <- matrix(unlist(arguments), ncol = 2, byrow = TRUE)
  # Create a linestring object
  linestring <- st_linestring(coordinates)

  return(linestring)
}
