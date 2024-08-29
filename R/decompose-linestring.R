#' Decompose a linestring into a list of line segments
#'
#' This function decomposes a linestring into a list of line segments,
#' where each segment is a linestring connecting two consecutive points
#' of the input linestring.
#'
#' @param linestring A linestring object.
#' @return A list of linestring objects, each representing a segment of the
#'   input linestring.
#' @export
#' @examples
#' # Create a linestring object
#' linestring <- create_linestring(0, 0, 1, 1, 2, 1, 4, 0)
#'
#' # Decompose the linestring into line segments
#' decompose_linestring(linestring)
decompose_linestring <- function(linestring) {
  # Extract the coordinates of the linestring
  coordinates <- st_coordinates(linestring)

  # Create a matrix of `from` and `to` points
  num_points <- nrow(coordinates)
  from <- coordinates[seq_len(num_points - 1), c("X", "Y"), drop = FALSE]
  to <- coordinates[seq_len(num_points - 1) + 1, c("X", "Y"), drop = FALSE]

  # Create a list of line segments
  segments <- apply(cbind(from, to), 1, create_linestring, simplify = FALSE)
  segments <- st_sfc(segments, crs = st_crs(linestring))

  return(segments)
}
