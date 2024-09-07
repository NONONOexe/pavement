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
#' road_network <- create_road_network(sample_roads)
#'
#' # Create a segmented road network
#' segmented_network <- create_segmented_network(
#'   road_network,
#'   segment_length = 0.5
#' )
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
    events         = NULL,
    origin_network = road_network,
    segment_length = segment_length
  ), class = "segmented_network")

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
  cat("\n")
  if (is.null(x$events)) {
    cat("Events: None\n")
  } else {
    cat("Events:\n")
    if (nrow(x$events) <= 5) {
      print(as.data.frame(x$events), ...)
    } else {
      print(as.data.frame(x$events)[1:5, ], ...)
      cat("...", nrow(x$events) - 5, "more events\n")
    }
  }
}

#' @export
plot.segmented_network <- function(
    x,
    y,
    mode = c("default", "event", "count", "density"),
    ...
    ) {
  mode <- match.arg(mode)

  if (mode == "event") {
    plot(x$links$geometry, lwd = 1, ...)
    plot(x$events$geometry, cex = 1, pch = 4, col = "red", add = TRUE, ...)
  } else if (mode %in% c("count", "density")) {
    plot_coloured_segmented_network(x$links$geometry, x$links[[mode]], ...)
    plot_legends(x$links[[mode]], mode, ...)
    reset_layout()
  } else {
    plot(x$links$geometry, lwd = 1, ...)
    plot(x$nodes$geometry, cex = 1, pch = 16, add = TRUE, ...)
  }
}

reset_layout <- function() {
  par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 2) + 0.1, oma = c(0, 0, 0, 0))
}

plot_coloured_segmented_network <- function(network_linestrings,
                                            segment_values,
                                            ...) {
  par(fig = c(0, 0.8, 0, 1), mar = c(5, 4, 4, 2))
  plot(network_linestrings, lwd = 1, ...)
  plot(
    network_linestrings,
    col = get_heatmap_colours(segment_values),
    lwd = ifelse(segment_values == 0, 1, 2),
    add = TRUE,
    ...
  )
}

plot_legends <- function(segment_values, mode, ...) {
  main <- switch (mode, count = "Count", density = "Probability\ndensity")
  digits <- ifelse(mode == "count", 0, 3)
  labels <- unique(round(seq(0, max(segment_values), length.out = 5), digits))

  par(
    fig = c(0.75, 0.95, 0.2, 0.8),
    mar = c(0, 0, 2.5, 0.5),
    cex.main = 0.8,
    cex.axis = 0.7,
    new = TRUE
  )
  plot(
    x = rep(1, 100),
    y = seq(0, 1, length.out = 100),
    xlim = c(0, 1),
    col = get_heatmap_colours(seq(0, 1, length.out = 100)),
    type = "n",
    xaxs = "i",
    yaxs = "i",
    axes = FALSE,
    main = main
  )
  segments(
    x0 = 0.45,
    x1 = 0.55,
    y0 = seq(0, 1, length.out = 100),
    y1 = seq(0, 1, length.out = 100),
    col = get_heatmap_colours(seq(0, 1, length.out = 100)),
    lwd = 20,
    lend = "butt"
  )
  axis(
    4,
    at = seq(0, 1, length.out = length(labels)),
    labels = labels,
    line = -2.0,
    tick = TRUE,
    las = 2
  )
}

get_heatmap_colours <- function(segment_values) {
  heatmap_colours <- paste0(heat.colors(100, rev = TRUE), "CD")
  normalized_values <- segment_values / max(segment_values)
  colours <- heatmap_colours[as.numeric(cut(normalized_values, breaks = 100))]

  return(colours)
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
