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
  edges <- st_drop_geometry(links)[, c("from", "to")]
  node_coordinates <- st_coordinates(nodes)
  vertices <- data.frame(
    id = nodes$id,
    x  = node_coordinates[, 1],
    y  = node_coordinates[, 2]
  )
  graph <- graph_from_data_frame(
    edges,
    directed = directed,
    vertices = vertices
  )

  # Set edge weights based on link length
  E(graph)$weight <- st_length(links)

  return(graph)
}
