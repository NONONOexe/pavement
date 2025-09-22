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
#' road_network <- create_road_network(sample_roads)
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
  links <- road_network$links

  # Create a lookup list that maps each link ID to its corresponding node indices
  link_node_map <- data.frame(
    node_index = rep(seq_len(nrow(nodes)), lengths(nodes$parent_link)),
    link_id    = unlist(nodes$parent_link)
  )
  nodes_indices_by_link <- split(link_node_map$node_index,
                                 link_node_map$link_id)

  # Convert the segmented nodes into multipoints grouped by parent link
  multipoints <- lapply(nodes_indices_by_link,
                        function(idx) sf::st_combine(nodes$geometry[idx]))
  multipoints_sfc <- do.call(c, multipoints)

  # Split all linestrings by their corresponding multipoints
  segments_list <- split_linestrings(links$geometry, multipoints_sfc, tolerance)

  # Combine the split linestrings into a single `sfc` object
  segments_sfc <- do.call(c, segments_list)
  sf::st_set_crs(segments_sfc, sf::st_crs(links))

  # Create a lookup vector to find node IDs from their geometry
  node_id_lookup <- stats::setNames(nodes$id, sf::st_as_text(nodes$geometry))

  # Get the `from` and `to` node IDs for each segment
  start_points_wkt <- sf::st_as_text(lwgeom::st_startpoint(segments_sfc))
  end_points_wkt   <- sf::st_as_text(lwgeom::st_endpoint(segments_sfc))
  from <- unname(node_id_lookup[start_points_wkt])
  to   <- unname(node_id_lookup[end_points_wkt])

  # Create a `sf` object representing the segmented network links
  network_links <- sf::st_sf(
    id          = sprintf("sl_%08x", seq_along(segments_sfc)),
    from        = from,
    to          = to,
    parent_link = rep(links$id, lengths(segments_list)),
    parent_road = rep(links$parent_road, lengths(segments_list)),
    count       = 0,
    density     = 0,
    geometry    = segments_sfc
  )

  return(network_links)
}
