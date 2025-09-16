#' Split a linestring into multiple segments
#'
#' @param linestring A linestring object.
#' @param split_points A `sfc` object containing points to split the
#'   linestring.
#' @param tolerance A numeric value representing the maximum distance
#'   allowed between the linestring and the split points. If the distance
#'   between a split point and the linestring exceeds this value, the point
#'   will not be used to split the linestring.
#' @return A `sfc` object containing the split linestrings.
#' @export
#' @examples
#' # Create a linestring
#' linestring <- create_linestring(0, -1, 0, 1, 2, 1, 2, 0, 0, 0)
#'
#' # Create a set of split points
#' split_points <- create_points(0, 0, 1, 1, 2, 0)
#'
#' # Plot the linestring and split points
#' plot(linestring)
#' plot(split_points, add = TRUE)
#'
#' # Split the linestring
#' segments <- split_linestring(linestring, split_points)
#'
#' # Plot the split linestrings
#' plot(segments, col = c("#E69F00", "#56B4E9", "#009E73", "#F0E442"), lwd = 2)
split_linestring <- function(linestring, split_points, tolerance = 0.01) {
  UseMethod("split_linestring")
}

#' @export
split_linestring.LINESTRING <- function(linestring,
                                        split_points,
                                        tolerance = 0.01) {
  linestring_sfc <- sf::st_sfc(linestring, crs = sf::st_crs(split_points))

  # Split the linestring into segments
  segments <- split_linestring.sfc_LINESTRING(linestring_sfc, split_points)
  segments <- sf::st_sfc(segments, crs = sf::st_crs(linestring))

  return(segments)
}

#' @export
split_linestring.sfc_LINESTRING <- function(linestring,
                                        split_points,
                                        tolerance = 0.01) {
  # Check if `linestring` is a single linestring
  if (length(linestring) != 1) {
    stop("`linestring` must be a single linestring")
  }

  # Decompose the linestring into a list of line segments
  line_segments <- decompose_linestring(linestring)

  # Identify split points on the line segments, remove those
  # near the endpoints, and add the start point of each line
  points_on_lines <- lapply(line_segments, function(line_segment) {
    valid_points <- filter_points_within_tolerance(
      split_points,
      line_segment,
      tolerance
    )
    valid_points <- remove_points_near_endpoints(
      valid_points,
      line_segment,
      tolerance
    )
    line_segment_sfc <- sf::st_sfc(line_segment, crs = sf::st_crs(split_points))
    distances_to_start_point <- as.vector(
      sf::st_distance(valid_points, st_startpoint(line_segment_sfc))
    )
    valid_points <- valid_points[order(distances_to_start_point)]
    c(st_startpoint(line_segment_sfc), valid_points)
  })

  # Combine all split points and add the end point of the linestring
  all_points <- sf::st_sfc(c(
    unlist(points_on_lines, recursive = FALSE),
    st_endpoint(linestring)
  ), crs = sf::st_crs(split_points))

  # Determine which points belong to each segment by calculating
  # the segment index
  is_split_point <- rep(FALSE, length(all_points))
  is_split_point[unlist(sf::st_contains(split_points, all_points))] <- TRUE
  is_split_point[c(1, length(all_points))] <- FALSE
  segment_index <- cumsum(is_split_point)

  # Split the list of points into sub-lists based on the segment index
  segment_points_list <- split(all_points, segment_index)
  segment_points_list[-length(segment_points_list)] <- mapply(
    c,
    segment_points_list[-length(segment_points_list)],
    lapply(all_points[is_split_point], sf::st_sfc, crs = sf::st_crs(split_points)),
    SIMPLIFY = FALSE
  )

  # Create linestring objects for each linestring segment
  segments <- sf::st_sfc(lapply(segment_points_list, function(segment_points) {
    sf::st_linestring(sf::st_coordinates(segment_points))
  }), crs = sf::st_crs(split_points))

  return(segments)
}
