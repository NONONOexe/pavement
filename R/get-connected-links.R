#' Get connected links from a node
#'
#' This function retrieves all links connected to a specified node in a road
#' network.
#'
#' @param network A road network object.
#' @param node_id The ID of the node.
#' @return A data frame containing the connected links.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#' target_node <- road_network$nodes[3,]
#' connected_links <- get_connected_links(road_network, target_node$id)
#'
#' # Plot the target node and the connected links
#' plot(road_network, col = "gray")
#' plot(connected_links$geometry, add = TRUE, col = "#D55E00", lwd = 2)
#' plot(target_node$geometry, add = TRUE, pch = 19)
get_connected_links <- function(network, node_id) {
  UseMethod("get_connected_links")
}

#' @export
get_connected_links.road_network <- function(network, node_id) {
  is_outgoing <- node_id == network$links$from
  is_incoming <- node_id == network$links$to
  connected_links <- network$links[is_outgoing | is_incoming, ]

  return(connected_links)
}
