#' Check if a point is a start or end point of linestring
#'
#' @param point A point object.
#' @param linestring A linestring object.
#' @return `TRUE` if the point is start or end point of the linestring,
#'   `FALSE` otherwise.
#' @export
is_linestring_endpoint <- function(point, linestring) {
  return(
    point == get_start_point(linestring) ||
    point == get_end_point(linestring)
  )
}
