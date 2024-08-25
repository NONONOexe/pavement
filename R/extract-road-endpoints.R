#' Extract road endpoints
#'
#' This function extracts the endpoints of a set of roads. It identifies
#' and counts the roads that intersect at each endpoint.
#'
#' @param roads A linestring object representing roads. It should be have
#'   a column named `road_id`.
#' @return A points object representing road endpoints. Each endpoint
#'   has the following columns:
#'   \itemize{
#'     \item origins: A list of road IDs that intersect at the endpoint.
#'     \item n.overlaps: The number of roads that intersect at the endpoint.
#'   }
#' @export
extract_road_endpoints <- function(roads) {
  # Extract the endpoints of the roads
  roads <- st_set_agr(roads, "constant")
  road_boundaries <- st_boundary(roads)
  road_boundaries <- road_boundaries[!st_is_empty(road_boundaries), ]
  road_boundaries <- st_cast(road_boundaries, "POINT")

  # Identify unique points among road endpoints, removing duplicates
  unique_points <- unique(road_boundaries$geometry)

  # Group road IDs by endpoint
  point_indices <- match(road_boundaries$geometry, unique_points)
  origin_road_ids_list <- split(road_boundaries$id, point_indices)

  # Create a simple feature object of road endpoints
  road_endpoints <- st_sf(
    parent_road  = I(origin_road_ids_list),
    num_overlaps = sapply(origin_road_ids_list, length),
    geometry     = st_sfc(unique_points, crs = st_crs(roads))
  )

  return(road_endpoints)
}
