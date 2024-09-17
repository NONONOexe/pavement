#' Create a road network from roads
#'
#' This function constructs a road network from a set of roads. The road
#' network is represented nodes and links between nodes. Nodes are defined
#' as intersections between roads and endpoints of road segments.
#'
#' @param roads A linestring object representing roads.
#' @param directed Logical indicating whether the road network is directed.
#' @param events A `sf` object representing events.
#' @param ... Additional arguments passed to or from other methods.
#' @returns A road network object.
#' @name road_network
#' @aliases create_road_network
#' @export
#' @examples
#' # Create the road network
#' road_network <- create_road_network(sample_roads)
#' road_network
#'
#' # Plot the road network
#' plot(road_network)
create_road_network <- function(roads, directed = FALSE, events = NULL, ...) {
  UseMethod("create_road_network")
}

#' @export
create_road_network.sf <- function(roads,
                                   directed = FALSE,
                                   events = NULL, ...) {
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

  # Assign events to the road network
  if (!is.null(events)) {
    road_network <- set_events(road_network, events)
  }

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
  if ("events" %in% names(x)) {
    cat("\n")
    cat("Events:\n")
    if (nrow(x$links) <= 5) {
      print(as.data.frame(x$events), ...)
    } else {
      print(as.data.frame(x$events)[1:5, ], ...)
      cat("...", nrow(x$links) - 5, "more events\n")
    }
  }
}

#' @export
plot.road_network <- function(x, y, mode = c("default", "event"), ...) {
  # Match the mode argument
  mode <- match.arg(mode)

  # Check if events are assigned to the road network
  if (mode == "event" && !("events" %in% names(x))) {
    stop("no events assigned to the road network")
  }

  plot(x$links$geometry, lwd = 1, ...)
  if (mode == "event") {
    plot(x$events$geometry, cex = 1, pch = 4, col = "red", add = TRUE, ...)
  } else {
    plot(x$nodes$geometry, cex = 1, pch = 16, add = TRUE, ...)
  }
}

#' @export
summary.road_network <- function(object, ...) {
  cat("Road network summary\n")
  cat("Number of nodes:  ", nrow(object$nodes), "\n")
  cat("Number of links:  ", nrow(object$links), "\n")
  if ("events" %in% names(object)) {
    cat("Number of events: ", nrow(object$events), "\n")
  }
}
