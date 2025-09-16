#' Extract road intersections
#'
#' This function identifies and extracts intersections between roads.
#' It considers only intersections where multiple roads on the same layer.
#'
#' @param roads A linestring object representing roads. It should be have
#'   a column named `layer` and a column named `road_id`.
#' @return A data frame with the following columns:
#'   \itemize{
#'     \item parent_road: A list of road IDs that intersect at the intersection.
#'     \item num_overlaps: The number of roads that intersect at the
#'       intersection.
#'   }
#' @export
#' @examples
#' # Extract road intersections
#' intersections <- extract_road_intersections(sample_roads)
#' intersections
#'
#' # Plot the intersections
#' plot(sample_roads$geometry)
#' plot(intersections$geometry, pch = 16, col = "#E69F00", add = TRUE)
extract_road_intersections <- function(roads) {
  # Retrieve the CRS from the input and convert to Cartesian system
  if (!is.na(sf::st_crs(roads)$input)) {
    roads <- transform_to_cartesian(roads)
  }

  # Compute the intersection points of the roads
  intersections <- sf::st_intersection(roads)
  intersections <- sf::st_set_agr(intersections, "constant")

  # Extract and cast geometries to points
  points <- get_points(intersections)

  # Restore original CRS to the points
  crs_roads <- sf::st_crs(roads)
  if (!is.na(crs_roads$input)) {
    points <- sf::st_transform(points, crs_roads)
  }

  # Remove duplicates
  n_overlaps_order <- order(points$n.overlaps, decreasing = TRUE)
  points <- points[n_overlaps_order, ]
  points <- points[!duplicated(points$geometry), ]

  # Filter intersections where more than one road overlaps
  points <- points[1 < points$n.overlaps, ]

  # For each intersections, get the list of roads that intersect there
  origin_roads_list <- lapply(points$origins, function(origins) {
    roads[as.integer(origins), ]
  })

  # Keep only intersections where all roads belong to the same layer
  is_same_layer <- vapply(origin_roads_list, function(origin_roads) {
    length(unique(origin_roads$layer)) == 1
  }, logical(1))
  points <- points[is_same_layer, ]

  # Convert data structure
  origin_road_ids_list <- lapply(points$origins, function(origins) {
    roads[as.integer(origins), ]$id
  })
  points <- sf::st_sf(
    parent_road  = I(origin_road_ids_list),
    num_overlaps = points$n.overlaps,
    geometry     = points$geometry
  )

  return(points)
}
