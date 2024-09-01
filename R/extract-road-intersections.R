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
extract_road_intersections <- function(roads) {
  # Find all intersections between roads
  intersections <- st_intersection(roads)

  # Remove duplicate intersections while keeping the intersection
  # with more overlaps
  n_overlaps_order <- order(intersections$n.overlaps, decreasing = TRUE)
  intersections <- intersections[n_overlaps_order, ]
  intersections <- intersections[!duplicated(intersections$geometry), ]

  # Remove intersections where only one road overlaps
  intersections <- intersections[1 < intersections$n.overlaps, ]

  # For each intersections, get the list of roads that intersect there
  origin_roads_list <- lapply(intersections$origins, function(origins) {
    roads[unlist(origins), ]
  })

  # Keep only intersections where all roads belong to the same layer
  is_same_layer <- sapply(origin_roads_list, function(origin_roads) {
    length(unique(origin_roads$layer)) == 1
  })
  intersections <- intersections[is_same_layer, ]

  # Convert data structure
  origin_road_ids_list <- lapply(intersections$origins, function(origins) {
    roads[unlist(origins), ]$id
  })
  intersections <- st_sf(
    parent_road  = I(origin_road_ids_list),
    num_overlaps = intersections$n.overlaps,
    geometry     = intersections$geometry
  )

  return(intersections)
}
