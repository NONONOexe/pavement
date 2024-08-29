#' Extract segmented network links from a road network
#'
#' This function extracts the segmented network links from a road network
#' based on a specified set of segmented network nodes. It splits the
#' linestrings of the road network links at the points of the segmented
#' network nodes to create the segmented network links.
#'
#' @param road_network A `road_network` object created with
#'   `create_road_network()`
#' @param segmented_network_nodes A data frame representing the segmented
#'   network nodes.
#' @param tolerance A numeric value representing the maximum distance allowed
#'   between a linestring of a road link and a point of a segmented network
#'   node. If the distance exceeds this value, the point will not be used to
#'   split the linestring.
#' @return A data frame representing the segmented network links.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#'
#' # Extract segmented network nodes by length of 1
#' segmented_network_nodes <- extract_segmented_network_nodes(road_network, 1)
#'
#' # Extract segmented network links
#' segmented_network_links <- extract_segmented_network_links(
#'   road_network,
#'   segmented_network_nodes
#' )
#' segmented_network_links
#'
#' # Plot the segmented network nodes and links
#' plot(segmented_network_links$geometry, col = "#E69F00")
#' plot(segmented_network_nodes$geometry, pch = 16, add = TRUE)
extract_segmented_network_links <- function(road_network,
                                            segmented_network_nodes,
                                            tolerance = 0.00001) {
  nodes <- segmented_network_nodes

  # Split the linestrings of the road network links at the points of the
  # segmented network nodes
  segments_list <- apply(road_network$links, 1, function(network_link) {
    # Find the segmented network nodes that belong to the current link
    split_points <- nodes$geometry[sapply(
      nodes$parent_link,
      function(parent_links) network_link$id %in% parent_links
    )]
    # Split the linestring of the current link at the found points
    split_linestring(network_link$geometry, split_points, tolerance)
  })
  # Combine the split linestrings into a single `sfc` object
  segments_sfc <- do.call(c, segments_list)

  # Get the `from` and `to` nodes for each segment
  from <- sapply(st_startpoint(segments_sfc), function(point) {
    nodes[which(sapply(nodes$geometry, identical, point)), ]$id
  })
  to <- sapply(st_endpoint(segments_sfc), function(point) {
    nodes[which(sapply(nodes$geometry, identical, point)), ]$id
  })

  # Create a `sf` object representing the segmented network links
  network_links <- st_sf(
    id          = sprintf("sl_%08x", seq_along(segments_sfc)),
    from        = from,
    to          = to,
    parent_link = rep(road_network$links$id, lengths(segments_list)),
    parent_road = rep(road_network$links$parent_road, lengths(segments_list)),
    geometry    = segments_sfc
  )

  return(network_links)
}
