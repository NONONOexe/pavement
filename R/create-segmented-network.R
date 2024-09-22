#' Create a segmented road network
#'
#' This function creates a segmented road network by dividing each link of the
#' input road network into segments of a specified length.
#'
#' @param road_network A `road_network` object representing the input road
#'   network.
#' @param segment_length A numeric value specifying the length of each segment.
#' @param events A `sf` object representing events.
#' @param ... Additional arguments passed to or from other methods.
#' @return A `segmented_network` object.
#' @name segmented_network
#' @aliases create_segmented_network
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
create_segmented_network <- function(road_network,
                                     segment_length = 1,
                                     events = NULL, ...) {
  UseMethod("create_segmented_network")
}

#' @rdname segmented_network
#' @export
create_segmented_network.road_network <- function(road_network,
                                                  segment_length = 1,
                                                  events = NULL, ...) {
  # Extract nodes and links of segmented road network
  nodes <- extract_segmented_network_nodes(road_network, segment_length)
  links <- extract_segmented_network_links(road_network, nodes)

  # Create graph from nodes and links
  graph <- create_graph(nodes,
                        links,
                        directed = is_directed(road_network$graph))

  # Construct the road network object
  segmented_network <- list(segments       = links,
                            graph          = graph,
                            nodes          = nodes,
                            origin_network = road_network,
                            segment_length = segment_length)
  class(segmented_network) <- "segmented_network"

  # Assign events if available
  if (!is.null(events) || !is.null(road_network$events)) {
    if (!is.null(events) && !is.null(road_network$events)) {
      warning("events already exist in the road network")
    }
    event_data <- if (!is.null(events)) events else road_network$events
    segmented_network <- set_events(segmented_network, event_data)
  }

  return(segmented_network)
}

#' @export
print.segmented_network <- function(x, ...) {
  cat("Segmented network", fill = TRUE)
  cat("Segment length: ", x$segment_length, fill = TRUE)
  cat("Segments:", fill = TRUE)
  print(as.data.frame(x$segments)[1:5, ])
  if (5 < nrow(x$segments))
    cat("...", nrow(x$segments) - 5, "more segments", fill = TRUE)
  if (is.null(x$events)) return(invisible(x))

  cat("Events:", fill = TRUE)
  print(as.data.frame(x$events)[1:5, ])
  if (5 < nrow(x$events))
    cat("...", nrow(x$segments) - 5, "more events", fill = TRUE)
}

#' @export
summary.segmented_network <- function(object, ...) {
  cat("Segmented network summary", fill = TRUE)
  cat("Segment length:", fill = TRUE)
  cat("  Desired: ", object$segment_length, fill = TRUE)
  cat("  Max.   : ", max(st_length(object$segments)), fill = TRUE)
  cat("  Mean   : ", mean(st_length(object$segments)), fill = TRUE)
  cat("  Min.   : ", min(st_length(object$segments)), fill = TRUE)
  cat("Number of segments: ", nrow(object$segments), fill = TRUE)
}

#' @export
plot.segmented_network <- function(x,
                                   y,
                                   mode = c("default", "event", "count", "density"),
                                   ...
                                   ) {
  mode <- match.arg(mode)

  if (mode == "event") {
    if (!("events" %in% names(x))) {
      stop("no events assigned to the road network")
    }
    plot_segments_and_points(x$segments$geometry, x$events$geometry,
                             col = "red", pch = 4, ...)
  } else if (mode %in% c("count", "density")) {
    plot_coloured_segmented_network(x$segments$geometry,
                                    x$segments[[mode]],
                                    mode, ...)
  } else {
    plot_segments_and_points(x$segments$geometry, x$nodes$geometry,
                             col = "black", pch = 16, ...)
  }
}

plot_segments_and_points <- function(segments, points, col, pch, ...) {
  plot(segments, lwd = 1, ...)
  plot(points, cex = 1, col = col, pch = pch, add = TRUE, ...)
}

plot_coloured_segmented_network <- function(segments,
                                            segment_values,
                                            mode,
                                            ...) {
  par(fig = c(0, 0.8, 0, 1), mar = c(5, 4, 4, 2))
  plot(segments, lwd = 1, ...)

  if (max(segment_values) == 0) {
    warning("all segment values are zero")
  } else {
    plot(segments,
         col = get_heatmap_colours(segment_values),
         lwd = ifelse(segment_values == 0, 1, 2),
         add = TRUE,
         ...)
  }

  plot_legends(segment_values, mode, ...)
  reset_layout()
}

plot_legends <- function(segment_values, mode, ...) {
  main <- switch(mode, count = "Count", density = "Probability\ndensity")
  digits <- ifelse(mode == "count", 0, 3)
  labels <- unique(round(seq(0, max(segment_values), length.out = 5), digits))

  par(fig = c(0.75, 0.95, 0.2, 0.8),
      mar = c(0, 0, 2.5, 0.5),
      cex.main = 0.8,
      cex.axis = 0.7,
      new = TRUE)
  plot(x = rep(1, 100),
       y = seq(0, 1, length.out = 100),
       xlim = c(0, 1),
       col = get_heatmap_colours(seq(0, 1, length.out = 100)),
       type = "n",
       xaxs = "i",
       yaxs = "i",
       axes = FALSE,
       main = main)

  segments(x0 = 0.45, x1 = 0.55,
           y0 = seq(0, 1, length.out = 100),
           y1 = seq(0, 1, length.out = 100),
           col = get_heatmap_colours(seq(0, 1, length.out = 100)),
           lwd = 20, lend = "butt")
  axis(4, at = seq(0, 1, length.out = length(labels)),
       labels = labels, line = -2.0, tick = TRUE, las = 2)
}

get_heatmap_colours <- function(segment_values) {
  heatmap_colours <- paste0(heat.colors(100, rev = TRUE), "CD")
  normalized_values <- segment_values / max(segment_values)
  colours <- heatmap_colours[as.numeric(cut(normalized_values, breaks = 100))]

  return(colours)
}

reset_layout <- function() {
  par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 2) + 0.1, oma = c(0, 0, 0, 0))
}
