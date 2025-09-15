#' Sample points along a linestring
#'
#' This function samples points at regular intervals along a linestring object.
#'
#' @param linestrings A `sfc` object containing linestrings.
#' @param segment_length The desired length of each segment between sampled
#'   points.
#' @return A `sfc` object containing the sampled points.
#' @export
#' @examples
#' library(sf)
#'
#' # Create a linestrings
#' linestrings <- c(
#'   create_linestring(0, 1, 2, 1),
#'   create_linestring(1, 1.3, 1, 0, 2, 0.5)
#' )
#'
#' # Sample points along the linestrings
#' sampled_points <- sample_points_along_linestring(linestrings, 0.5)
#'
#' # Plot the sampled points
#' plot(linestrings)
#' plot(sampled_points, add = TRUE, pch = 16, col = c("#E69F00", "#56B4E9"))
sample_points_along_linestring <- function(linestrings, segment_length) {
  # Check if `segment_length` is valid
  if (segment_length <= 0) {
    stop("`segment_length` must be greater than 0")
  }

  # Calculate the number of segments to sample along each linestring
  linestrings_length <- sf::st_length(linestrings)
  num_segments <- as.integer(round(linestrings_length / segment_length))

  # Sample points along each linestring segment
  sampled_points <- lapply(
    seq_along(linestrings),
    function(i) {
      sampling_positions <- seq(0, 1, length.out = num_segments[i] + 1)
      sampling_positions <- sampling_positions[-c(1, num_segments[i] + 1)]
      sf::st_line_sample(linestrings[i], sample = sampling_positions)
    }
  )

  # Combine the list of sampled points into a single `sfc` object
  sampled_points_sfc <- do.call(c, sampled_points)

  return(sampled_points_sfc)
}
