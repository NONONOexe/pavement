#' Split a line into multiple lines
#'
#' This function splits a line into multiple lines at specified points.
#'
#' @param line A `LINESTRING` object.
#' @param split_points A `sfc` object containing points to split the line.
#' @param tolerance A numeric value representing the maximum distance
#'   between the line and the split points. If the distance between a
#'   split point and the line is greater than this value, the point
#'   will not be used to split the line.
#' @return A `sfc` object containing the split lines.
#' @export
#' @examples
#' library(sf)
#'
#' # Create a line
#' line <- create_linestring(0, 0, 5, 5)
#'
#' # Create a set of points
#' split_points <- st_sfc(
#'   st_point(c(0.0, 0.0)),
#'   st_point(c(3.5, 3.5)),
#'   st_point(c(1.0, 1.0))
#' )
#'
#' # Plot the line and split points
#' plot(line)
#' plot(split_points, add = TRUE, pch = 3, lwd = 2)
#'
#' # Split the line at the specified points
#' split_lines <- split_line(line, split_points)
#'
#' # Plot the split lines
#' plot(split_lines, lwd = 2, col = c("#E69F00", "#56B4E9", "#009E73"))
split_line <- function(line, split_points, tolerance = 0.01) {
  UseMethod("split_line")
}

#' @export
split_line.LINESTRING <- function(line, split_points, tolerance = 0.01) {
  if (nrow(st_coordinates(line)) != 2) {
    stop("`line` must be defined by two points")
  }

  # Filter points that are within the torelance distance from the line
  points <- split_points[st_distance(line, split_points)[1, ] <= tolerance]

  # Get start and end points of the line
  start_point <- st_startpoint(line)
  end_point <- st_endpoint(line)

  # Remove points that are too close to the start or end points
  points <- points[
    (tolerance < st_distance(start_point, points)[1, ]) &
    (tolerance < st_distance(end_point, points)[1, ])
  ]

  # Sort points by distance to the start point
  points <- points[order(st_distance(start_point, points))]

  # Combine coordinates of the start point, split points, and end point
  coordinates <- rbind(
    st_coordinates(start_point),
    st_coordinates(points),
    st_coordinates(end_point)
  )

  # Create a list of linestrings connecting consecutive points
  coordinates <- cbind(coordinates[-nrow(coordinates), ], coordinates[-1, ])
  split_lines <- st_sfc(apply(coordinates, 1, create_linestring, simplify = FALSE))

  return(split_lines)
}
