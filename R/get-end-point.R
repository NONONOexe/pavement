#' Get the end point of a "LINESTRING" or "MULTILINESTRING"
#'
#' This function extracts the end point of a "LINESTRING" or "MULTILINESTRING"
#'
#' @param x A "LINESTRING" or "MULTILINESTRING" object.
#' @return
#'   For "LINESTRING" input, returns a "POINT" object representing the end
#'   point.
#'   For "MULTILINESTRING" input, returns a "MULTIPOINT" object representing
#'   the end points of each "LINESTRING".
#' @seealso [get_start_point()] for obtaining the start point
#' @export
#' @examples
#' # Example for "LINESTRING"
#' linestring <- structure(matrix(
#'   c(0, 0, 1, 1, 2, 1),
#'   ncol = 2, byrow = TRUE
#' ), class = c("XY", "LINESTRING", "sfg"))
#' end_point <- get_end_point(linestring)
#' plot(linestring)
#' plot(end_point, add = TRUE)
#'
#' # Example for "MULTILINESTRING"
#' multilinestring <- structure(list(
#'   matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE),
#'   matrix(c(2, 1, 3, 2), ncol = 2, byrow = TRUE)
#' ), class = c("XY", "MULTILINESTRING", "sfg"))
#' end_points <- get_end_point(multilinestring)
#' plot(multilinestring)
#' plot(end_points, add = TRUE)
get_end_point <- function(x) {
  UseMethod("get_end_point")
}

#' @export
get_end_point.LINESTRING <- function(x) {
  linestring_coordinates <- unclass(x)
  end_point <- get_end_point(linestring_coordinates)

  return(end_point)
}

#' @export
get_end_point.MULTILINESTRING <- function(x) {
  end_point_coordinates <- matrix(
    unlist(lapply(x, get_end_point)),
    ncol = 2, byrow = TRUE
  )
  end_points <- structure(
    end_point_coordinates,
    class = c("XY", "MULTIPOINT", "sfg")
  )

  return(end_points)
}

#' @export
get_end_point.matrix <- function(x) {
  n_points <- nrow(x)
  end_point_coordinates <- x[n_points, , drop = FALSE]
  end_point <- structure(
    end_point_coordinates,
    class = c("XY", "POINT", "sfg")
  )

  return(end_point)
}
