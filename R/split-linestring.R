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

  # Calculate distances from all points to the entire linestring at once
  distances <- sf::st_distance(split_points, linestring)

  # Filter points that are within the specified tolerance
  valid_points <- split_points[as.numeric(distances) <= tolerance, ]

  # If no valid points remain, return the original linestring
  if (length(valid_points) == 0) {
    return(linestring)
  }

  # For each valid point, find the nearest point on the linestring (snap)
  nearest_points_on_line <- sf::st_cast(
    sf::st_nearest_points(valid_points, linestring), "POINT"
  )
  snapped_points <- nearest_points_on_line[seq(2, length(nearest_points_on_line), by = 2)]

  # Combine the snapped points into a single MULTIPOINT to use as a splitting blade
  split_blade <- sf::st_union(snapped_points)

  # Split the linestring with the blade of points
  split_result <- lwgeom::st_split(linestring, split_blade)

  # Extract the resulting LINESTRINGs, from the GEOMETRYCOLLECTION
  segments <- sf::st_collection_extract(split_result, "LINESTRING")
  segments <- sf::st_sfc(segments, crs = sf::st_crs(linestring))

  return(segments)
}
