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
#' nodes <- extract_road_network_nodes(demo_roads)
#' links <- extract_road_network_links(demo_roads, nodes)
#'
#' # Create the graph
#' graph <- create_graph(nodes, links)
#'
#' # Plot the graph
#' plot(graph)
create_graph <- function(nodes, links, directed = FALSE) {
  # Create graph from nodes and links
  graph_links <- st_drop_geometry(links)[, c("from", "to", "id")]
  graph_nodes <- create_graph_nodes(nodes$id, nodes$geometry)
  graph <- graph_from_data_frame(
    graph_links,
    directed = directed,
    vertices = graph_nodes
  )

  # Set edge weights based on link length
  E(graph)$weight <- st_length(links)

  return(graph)
}
