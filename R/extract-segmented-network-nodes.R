#' Extract nodes of segmented network from a road network
#'
#' This function extracts nodes at regular intervals along each link in
#' a road network
#'
#' @param road_network A `road_network` object created with `create_network()`.
#' @param segment_length The length of each segment to sample along the links.
#' @return An `sf` object with the sampled points.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#'
#' # Extract nodes with a segment length of 1
#' segmented_network_nodes <- extract_segmented_network_nodes(road_network, 1)
#' segmented_network_nodes
#'
#' # Plot the segmented network nodes
#' plot(road_network)
#' plot(segmented_network_nodes$geometry, add = TRUE, pch = 16, col = "#E69F00")
extract_segmented_network_nodes <- function(road_network, segment_length) {
  UseMethod("extract_segmented_network_nodes")
}

#' @export
extract_segmented_network_nodes.road_network <- function(
    road_network,
    segment_length) {
  # Attach parent link IDs to nodes
  nodes <- road_network$nodes
  nodes$parent_link <- I(lapply(road_network$nodes$id, function(id) {
    get_connected_links(road_network, id)$id
  }))

  # Sample points along each link geometry
  sampled_points <- sample_points_along_linestring(
    road_network$links$geometry,
    segment_length
  )
  sampled_nodes <- st_sf(
    parent_link = road_network$links$id,
    parent_road = road_network$links$parent_road,
    geometry    = sampled_points,
    crs         = st_crs(road_network$links),
    agr         = "constant"
  )
  sampled_nodes <- sampled_nodes[!st_is_empty(sampled_nodes), ]
  sampled_nodes <- st_cast(sampled_nodes, "POINT")

  # Combine the list of data frames into a single `sf` object
  combined_nodes <- rbind(nodes[c("parent_link", "parent_road")], sampled_nodes)
  combined_nodes <- st_set_agr(combined_nodes, "constant")

  # Assign unique IDs to nodes
  combined_nodes$id <- generate_ids(combined_nodes$parent_link, "sn_%08x")
  combined_nodes <- combined_nodes[order(combined_nodes$id), ]
  row.names(combined_nodes) <- NULL

  return(combined_nodes[c("id", "parent_link", "parent_road")])
}
