#' Get the start point of a "LINESTRING" or "MULTILINESTRING"
#'
#' This function extracts the start point of a "LINESTRING" or
#' "MULTILINESTRING"
#'
#' @param x A "LINESTRING" or "MULTILINESTRING" object.
#' @return
#'   For "LINESTRING" input, returns a "POINT" object representing the start
#'   point.
#'   For "MULTILINESTRING" input, returns a "MULTIPOINT" object representing
#'   the start points of each "LINESTRING".
#' @seealso [get_start_point()] for obtaining the start point
#' @export
#' @examples
#' # Example for "LINESTRING"
#' linestring <- structure(matrix(
#'   c(0, 0, 1, 1, 2, 1),
#'   ncol = 2, byrow = TRUE
#' ), class = c("XY", "LINESTRING", "sfg"))
#' start_point <- get_start_point(linestring)
#' plot(linestring)
#' plot(start_point, add = TRUE)
#'
#' # Example for "MULTILINESTRING"
#' multilinestring <- structure(list(
#'   matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE),
#'   matrix(c(2, 1, 3, 2), ncol = 2, byrow = TRUE)
#' ), class = c("XY", "MULTILINESTRING", "sfg"))
#' start_points <- get_start_point(multilinestring)
#' plot(multilinestring)
#' plot(start_points, add = TRUE)
get_start_point <- function(x) {
  UseMethod("get_start_point")
}

#' @export
get_start_point.LINESTRING <- function(x) {
  linestring_coordinates <- unclass(x)
  start_point <- get_start_point(linestring_coordinates)

  return(start_point)
}

#' @export
get_start_point.MULTILINESTRING <- function(x) {
  start_point_coordinates <- matrix(
    unlist(lapply(x, get_start_point)),
    ncol = 2, byrow = TRUE
  )
  start_points <- structure(
    start_point_coordinates,
    class = c("XY", "MULTIPOINT", "sfg")
  )

  return(start_points)
}

#' @export
get_start_point.matrix <- function(x) {
  start_point_coordinates <- x[1, , drop = FALSE]
  start_point <- structure(
    start_point_coordinates,
    class = c("XY", "POINT", "sfg")
  )

  return(start_point)
}
