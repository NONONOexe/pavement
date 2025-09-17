#' Sample points along a linestring
#'
#' This function samples points at regular intervals along a linestring object.
#'
#' @param linestrings A `sfc` object containing linestrings.
#' @param segment_length The desired length of each segment between sampled
#'   points.
#' @return A `sfc` object containing the sampled points, grouped as MULTIPOINTs
#'   for each input linestring.
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

  # Get the list of coordinate matrices from the C++ function
  coords_list <- sample_points_cpp(linestrings, segment_length)

  # Process the list to create a list of MULTIPOINT geometries
  multipoints_list <- lapply(coords_list, function(coords) {
    # If the matrix has rows, create a MULTIPOINT
    if (0 < nrow(coords)) {
      return(sf::st_multipoint(coords))
    } else {
      return(sf::st_multipoint())
    }
  })

  # Combine the list of MULTIPOINT geometries into a single sfc object
  sampled_points_sfc <- sf::st_sfc(multipoints_list,
                                   crs = sf::st_crs(linestrings))

  return(sampled_points_sfc)
}
