#' Create a graph from nodes and links
#'
#' This function creates a graph object from a set of nodes and links.
#'
#' @param nodes A `sf` object representing nodes.
#' @param links A `sf` object representing links between nodes.
#' @param directed A logical indicating whether the graph is directed.
#' @return A `igraph` object.
#' @export
#' @examples
#' # Create nodes and links
#' nodes <- extract_road_network_nodes(sample_roads)
#' links <- extract_road_network_links(sample_roads, nodes)
#'
#' # Create the graph
#' graph <- create_graph(nodes, links)
#' graph
#'
#' # Plot the graph
#' plot(graph)
create_graph <- function(nodes, links, directed = FALSE) {
  # Create graph nodes
  node_coordinates <- sf::st_coordinates(nodes$geometry)
  graph_nodes <- data.frame(
    name = nodes$id,
    x    = node_coordinates[, "X"],
    y    = node_coordinates[, "Y"]
  )

  # Create graph links
  link_cooridnates <- sf::st_coordinates(sf::st_centroid(links$geometry))
  graph_links <- data.frame(
    from   = links$from,
    to     = links$to,
    name   = links$id,
    x      = link_cooridnates[, "X"],
    y      = link_cooridnates[, "Y"],
    weight = sf::st_length(links$geometry)
  )

  graph <- igraph::graph_from_data_frame(
    graph_links,
    directed = directed,
    vertices = graph_nodes
  )

  return(graph)
}
