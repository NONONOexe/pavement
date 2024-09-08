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
  line_graph <- make_line_graph(network$graph)

  V(line_graph)$name <- E(network$graph)$name
  V(line_graph)$x <- E(network$graph)$x
  V(line_graph)$y <- E(network$graph)$y

  E(line_graph)$name <- apply(as_edgelist(line_graph), 1, function(links) {
    edge_1_nodes <- ends(network$graph, E(network$graph)[links[1]])
    edge_2_nodes <- ends(network$graph, E(network$graph)[links[2]])
    intersect(edge_1_nodes, edge_2_nodes)
  })
  E(line_graph)$x <- V(network$graph)[E(line_graph)$name]$x
  E(line_graph)$y <- V(network$graph)[E(line_graph)$name]$y
  E(line_graph)$weight <- apply(as_edgelist(line_graph), 1, function(links) {
    (E(network$graph)[links[1]]$weight + E(network$graph)[links[2]]$weight) / 2
  })

  return(line_graph)
}
