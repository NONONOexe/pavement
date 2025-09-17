#' Create a line graph from a network
#'
#' This function creates a line graph where nodes represent the midpoints
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
#' graph <- create_line_graph(network)
#'
#' # Plot the midpoint graph
#' plot(graph)
create_line_graph <- function(network) {
  line_graph <- igraph::make_line_graph(network$graph)

  V(line_graph)$name <- E(network$graph)$name
  V(line_graph)$x <- E(network$graph)$x
  V(line_graph)$y <- E(network$graph)$y

  # Get the edge lists for both graphs once to avoid repeated calls
  line_graph_edges <- igraph::as_edgelist(line_graph, names = FALSE)
  original_edges   <- igraph::as_edgelist(network$graph, names = FALSE)

  # Get the endpoints of the original edges
  edges1_nodes <- original_edges[line_graph_edges[, 1], ]
  edges2_nodes <- original_edges[line_graph_edges[, 2], ]

  # Identify the shared node ID for each edge
  common_node_ids <- ifelse(
    edges1_nodes[, 1] == edges2_nodes[, 1] |
    edges1_nodes[, 1] == edges2_nodes[, 2],
    edges1_nodes[, 1],
    edges1_nodes[, 2]
  )

  # Set the edge attributes based on the shared node's properties
  E(line_graph)$name <- V(network$graph)$name[common_node_ids]
  E(line_graph)$x <- V(network$graph)$x[common_node_ids]
  E(line_graph)$y <- V(network$graph)$y[common_node_ids]

  # Get all weights from the original graph
  original_weights <- E(network$graph)$weight

  # Create two weight vectors corresponding to the two original edges
  weights1 <- original_weights[line_graph_edges[, 1]]
  weights2 <- original_weights[line_graph_edges[, 2]]

  # Calculate the average weight
  E(line_graph)$weight <- (weights1 + weights2) / 2

  return(line_graph)
}
