#' Create spatiotemporal network
#'
#' This function creates a spatiotemporal network from a road network.
#'
#' @param road_network A `road_network` object.
#' @param spatial_length The spatial length of segment.
#' @param temporal_length The temporal length of segment.
#' @param events A event collection object.
#' @param ... Additional arguments passed to or from other methods.
#' @return A `spatiotemporal_network` object.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(sample_roads)
#'
#' # Create a spatiotemporal road network
#' spatiotemporal_network <- create_spatiotemporal_network(
#'   road_network,
#'   spatial_length = 0.5,
#'   temporal_length = "4 hour"
#' )
#' spatiotemporal_network
#'
#' # Plot the spatiotemporal road network
#' plot(spatiotemporal_network)
create_spatiotemporal_network <- function(road_network,
                                          spatial_length = 1,
                                          temporal_length = "1 hour",
                                          events = NULL,
                                          ...) {
  UseMethod("create_spatiotemporal_network")
}

#' @export
create_spatiotemporal_network.road_network <- function(road_network,
                                                       spatial_length = 1,
                                                       temporal_length = "1 hour",
                                                       events = NULL,
                                                       ...) {
  # Extract network nodes and links
  network_nodes <- extract_segmented_network_nodes(road_network, spatial_length)
  network_links <- extract_segmented_network_links(road_network, network_nodes)
  spatial_graph <- create_graph(network_nodes, network_links,
                                directed = is_directed(road_network$graph))

  # Create time intervals
  network_durations <- create_durations(temporal_length)

  # Calculate the total number of spatiotemporal segments
  num_segments <- nrow(network_links)
  num_intervals <- nrow(network_durations)
  total_segments <- num_segments * num_intervals

  # Replicate segments for each time interval
  spatiotemporal_segments <- data.frame(
    id       = sprintf("ts_%010x", seq_len(total_segments)),
    geometry = rep(network_links$id, num_intervals),
    duration = rep(network_durations$id, each = num_segments),
    count    = 0,
    density  = 0
  )

  # Create the spatiotemporal network object
  spatiotemporal_network <- list(
    segments           = spatiotemporal_segments,
    segment_geometries = network_links,
    segment_durations  = network_durations,
    spatial_graph      = spatial_graph,
    origin_network     = road_network,
    spatial_length     = spatial_length,
    temporal_length    = temporal_length
  )
  class(spatiotemporal_network) <- "spatiotemporal_network"

  # Assign events if available
  if (!is.null(events) || !is.null(road_network$events)) {
    if (!is.null(events) && !is.null(road_network$events)) {
      warning("events already exist in the road network")
    }
    spatiotemporal_network <- set_events(spatiotemporal_network,
                                         events %||% road_network$events)
  }

  return(spatiotemporal_network)
}

#' @export
plot.spatiotemporal_network <- function(x, y, ...) {
  plot(x$segment_geometries$geometry, ...)
}
