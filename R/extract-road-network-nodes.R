#' Extract road network nodes
#'
#' This function extracts nodes from roads represented as linestring objects
#' downloaded from OpenStreetMap. Nodes are defined as intersections between
#' roads and endpoints of road segments.
#'
#' @param roads A linestring object representing roads.
#' @return A points object representing road network nodes.
#' @export
extract_road_network_nodes <- function(roads) {
  # Extract road intersections
  intersections <- extract_road_intersections(roads)

  # Extract road endpoints
  endpoints <- extract_road_endpoints(roads)

  # Convert data structures and merge intersection and endpoint nodes
  network_nodes <- rbind(intersections, endpoints)

  # Remove duplicate nodes
  is_unique <- !duplicated(network_nodes$geometry)
  network_nodes <- network_nodes[is_unique, ]

  # Assign unique IDs to nodes
  first_ids <- sapply(network_nodes$parent_road, function(road) road[1])
  id_numbers <- strtoi(substr(first_ids, 7 - 3, 7), base = 16)
  indices <- rank(id_numbers, ties.method = "first")
  network_nodes$id <- sprintf("jn_%06x", indices)
  network_nodes <- network_nodes[order(indices), ]

  # Select columns and set row names
  network_nodes <- network_nodes[c("id", "parent_road", "num_overlaps")]
  rownames(network_nodes) <- network_nodes$id

  return(network_nodes)
}
