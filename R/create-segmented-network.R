#' Create a segmented road network
#'
#' This function creates a segmented road network by dividing each link of the
#' input road network into segments of a specified length.
#'
#' @param road_network A `road_network` object representing the input road
#'   network.
#' @param segment_length A numeric value specifying the length of each segment.
#' @return A `segmented_network` object.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#'
#' # Create a segmented road network
#' segmented_network <- create_segmented_network(road_network)
#' segmented_network
#'
#' # Plot the segmented road network
#' plot(segmented_network)
create_segmented_network <- function(road_network, segment_length = 1) {
  # Extract nodes and links of segmented road network
  nodes <- extract_segmented_network_nodes(road_network, segment_length)
  links <- extract_segmented_network_links(road_network, nodes)

  # Create graph from nodes and links
  graph <- create_graph(
    nodes,
    links,
    directed = is_directed(road_network$graph)
  )

  # Construct the road network object
  segmented_network <- structure(list(
    graph          = graph,
    nodes          = nodes,
    links          = links,
    origin_network = road_network,
    segment_length = segment_length
  ), class = c("segmented_network"))

  return(segmented_network)
}

#' @export
print.segmented_network <- function(x, ...) {
  cat("Segmented network\n")
  cat("Segment length: ", x$segment_length, "\n")
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
plot.segmented_network <- function(x, ...) {
  plot(x$links$geometry, lwd = 1, ...)
  plot(x$nodes$geometry, cex = 1, pch = 16, add = TRUE, ...)
}

#' @export
summary.segmented_network <- function(object, ...) {
  cat("Segmented network summary\n")
  cat("Segment length:\n")
  cat("  Desired: ", object$segment_length, "\n")
  cat("  Max.   : ", max(st_length(object$links)), "\n")
  cat("  Mean   : ", mean(st_length(object$links)), "\n")
  cat("  Min.   : ", min(st_length(object$links)), "\n")
  cat("Number of nodes: ", nrow(object$nodes), "\n")
  cat("Number of links: ", nrow(object$links), "\n")
}
