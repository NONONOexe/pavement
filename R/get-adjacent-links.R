#' Get adjacent links of a specified link
#'
#' This function returns a vector of link IDs that are adjacent to a specified
#' link in a road network.
#'
#' @param network A `road_network` or `segmented_network` object.
#' @param link_ids The ID of the link to find adjacent links for.
#' @param reachable_only If `FALSE`, the default, all adjacent links are
#'   returned. If `TRUE`, only reachable links are returned.
#' @return A vector of link ID adjacent to the specified link.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(sample_roads)
#' target_link <- road_network$links$id[7]
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
#' plot(road_network$links$geometry[7], add = TRUE, pch = 19)
#' plot(adjacent_links_geom, add = TRUE, col = "#E69F00", lwd = 2)
get_adjacent_links <- function(network, link_ids, reachable_only = FALSE) {
  # Extract all links
  all_links <- network$links

  # Extract the links with the specified ID
  links <- all_links[all_links$id %in% link_ids, ]

  # Find the adjacent links
  adjacent_links <- apply(links, 1, function(link) {
    if (reachable_only && is_directed(network$graph)) {
      all_links$id[all_links$from == link$to]
    } else {
      link_ids <- get_connected_links(network, c(link$to, link$from))
      link_ids[link_ids != link$id]
    }
  })
  adjacent_links <- unname(adjacent_links)

  return(adjacent_links)
}
