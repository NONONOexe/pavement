#' Create a collection of coordinates.
#'
#' This function creates a collection of coordinates from a sequence
#' x and y coordinates.
#'
#' @param ... A sequence of x and y coordinates.
#' @return A `coordinates` object which is a matrix with x and y columns.
#' @export
#' @examples
#' # Create a `coordinates` object from a sequence of x and y coordinates
#' create_coordinates(1, 2, 3, 4)
#'
#' # Create a `coordinates` object from an with a vector of x and y
#' # coordinates
#' create_coordinates(c(1, 2, 3, 4))
create_coordinates <- function(...) {
  # Collect all arguments
  coordinates_dbl <- c(...)

  # If no arguments are provided, return an empty collection of points
  if (length(coordinates_dbl) == 0) {
    coordinates_dbl <- double()
  }

  # Check if the number of arguments is even
  if (length(coordinates_dbl) %% 2 != 0) {
    stop("arguments must be provided in pairs (x, y) coordinates")
  }

  # Create a matrix of coordinates
  coordinates <- structure(
    matrix(coordinates_dbl, ncol = 2, byrow = TRUE),
    class = "coordinates"
  )

  return(coordinates)
}

#' @export
print.coordinates <- function(x, ...) {
  cat("{")
  cat(apply(x, 1, function(c) paste0("(", paste(c, collapse = ", "), ")")))
  cat("}")
}
