#' Get adjacent links of a specified link
#'
#' This function returns a vector of link IDs that are adjacent to a specified
#' link in a road network.
#'
#' @param network A `road_network` or `segmented_network` object.
#' @param link_id The ID of the link to find adjacent links for.
#' @return A vector of link IDs adjacent to the specified link.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#' target_link <- road_network$links[3,]$id
#' target_link
#'
#' # Get adjacent links
#' adjacent_links <- get_adjacent_links(road_network, target_link)
#' adjacent_links
#'
#' # Plot the target link and the adjacent links
#' is_adjacent <- road_network$links$id %in% adjacent_links
#' adjacent_links_geom <- road_network$links$geometry[is_adjacent]
#' plot(road_network, col = "gray")
#' plot(road_network$links[3,]$geometry, add = TRUE, pch = 19)
#' plot(adjacent_links_geom, add = TRUE, col = "#E69F00", lwd = 2)
get_adjacent_links <- function(network, link_id) {
  # Extract the link with the specified ID
  link <- network$links[network$links$id == link_id, ]

  # Get the nodes connected to the specified link
  nodes <- c(link$from, link$to)

  # Find the adjacent links
  is_other <- network$links$id != link_id
  is_connected <- network$links$from %in% nodes | network$links$to %in% nodes
  adjacent_links <- network$links$id[is_other & is_connected]

  return(adjacent_links)
}
