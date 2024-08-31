#' Create a road network from roads
#'
#' This function constructs a road network from a set of roads. The road
#' network is represented nodes and links between nodes. Nodes are defined
#' as intersections between roads and endpoints of road segments.
#'
#' @param roads A linestring object representing roads.
#' @param directed Logical indicating whether the road network is directed.
#' @returns A road network object.
#' @export
#' @examples
#' # Create the road network
#' road_network <- create_road_network(sample_roads)
#' road_network
#'
#' # Plot the road network
#' plot(road_network)
create_road_network <- function(roads, directed = FALSE) {
  # Extract nodes and links of road network
  nodes <- extract_road_network_nodes(roads)
  links <- extract_road_network_links(roads, nodes)

  # Create graph from nodes and links
  graph <- create_graph(nodes, links, directed)

  # Construct the road network object
  road_network <- structure(list(
    graph = graph,
    nodes = nodes,
    links = links,
    roads = roads
  ), class = "road_network")

  return(road_network)
}

#' @export
print.road_network <- function(x, ...) {
  cat("Road network\n")
  cat("Nodes:\n")
  if (nrow(x$nodes) <= 5) {
    print(as.data.frame(x$nodes), ...)
  } else {
    print(as.data.frame(x$nodes)[1:5, ], ...)
    cat("...", nrow(x$nodes) - 5, "more nodes\n")
  }
  cat("\n")
  cat("Links:\n")
  if (nrow(x$links) <= 5) {
    print(as.data.frame(x$links), ...)
  } else {
    print(as.data.frame(x$links)[1:5, ], ...)
    cat("...", nrow(x$links) - 5, "more links\n")
  }
}

#' @export
plot.road_network <- function(x, y, ...) {
  plot(x$links$geometry, lwd = 1, ...)
  plot(x$nodes$geometry, cex = 1, pch = 16, add = TRUE, ...)
}

#' @export
summary.road_network <- function(object, ...) {
  cat("Road network summary\n")
  cat("Number of nodes: ", nrow(object$nodes), "\n")
  cat("Number of links: ", nrow(object$links), "\n")
}
