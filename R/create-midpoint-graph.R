#' Create a midpoint graph from a network
#'
#' This function creates a midpoint graph where nodes represent the midpoints
#' of links in the input network.
#'
#' @param network A `road_network` or `segmented_network` object.
#' @return A `igraph` object representing the midpoint graph.
#' @export
#' @examples
#' # Create a road network
#' network <- create_road_network(sample_roads)
#'
#' # Plot the road network
#' plot(network$graph)
#'
#' # Create a midpoint graph from a road network
#' graph <- create_midpoint_graph(network)
#'
#' # Plot the midpoint graph
#' plot(graph)
create_midpoint_graph <- function(network) {
  # Get adjacent links for each link
  adjacent_links <- get_adjacent_links(
    network,
    network$links$id,
    reachable_only = TRUE
  )

  # Create a data frame of links for midpoint graph
  midpoint_graph_links <- create_graph_links(
    rep(network$links$id, lengths(adjacent_links)),
    unlist(adjacent_links),
    directed     = is_directed(network$graph),
    unique_links = TRUE
  )

  # Create a data frame of nodes for midpoint graph
  midpoint_graph_nodes <- create_graph_nodes(
    network$links$id,
    st_centroid(network$links$geometry)
  )

  # Create a midpoint graph from the links and nodes
  midpoint_graph <- graph_from_data_frame(
    midpoint_graph_links,
    directed = is_directed(network$graph),
    vertices = midpoint_graph_nodes
  )

  # Calculate weights for each edge
  link_indices <- match(as.matrix(midpoint_graph_links), network$links$id)
  link_length <- st_length(network$links$geometry[link_indices])
  E(midpoint_graph)$weight <- rowMeans(matrix(link_length, ncol = 2))

  return(midpoint_graph)
}
