#' Get connected links from a specified node
#'
#' This function retrieves all links connected to a specified node in a road
#' network.
#'
#' @param network A `road_network` or `segmented_network` object.
#' @param node_id The ID of the node.
#' @return A vector of link IDs connected to the specified node.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#' target_node <- road_network$nodes[3,]$id
#' target_node
#'
#' # Get connected links
#' connected_links <- get_connected_links(road_network, target_node)
#' connected_links
#'
#' # Plot the target node and the connected links
#' is_connected <- road_network$links$id %in% connected_links
#' connected_links_geom <- road_network$links$geometry[is_connected]
#' plot(road_network, col = "gray")
#' plot(connected_links_geom, add = TRUE, col = "#E69F00", lwd = 2)
#' plot(road_network$nodes[3,]$geometry, add = TRUE, pch = 19)
get_connected_links <- function(network, node_id) {
  is_outgoing <- node_id == network$links$from
  is_incoming <- node_id == network$links$to
  connected_links <- network$links[is_outgoing | is_incoming, ]$id

  return(connected_links)
}
