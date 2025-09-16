#' Set events on a space.
#'
#' This function sets events on a space.
#'
#' @param x A space object.
#' @param events A sf or spatiotemporal events object.
#' @param ... Additional arguments passed to or from other methods.
#' @return The input object with the events added.
#' @export
#' @examples
#' # Create the road network
#' road_network <- create_road_network(sample_roads)
#'
#' # Set accidents on the road network
#' road_network <- set_events(road_network, sample_accidents)
set_events <- function(x, events, ...) {
  UseMethod("set_events")
}

validate_and_set_events <- function(x, events, type) {
  if (!inherits(events, type)) {
    stop("events must be a `", type, "` object")
  }
  if ("events" %in% names(x)) {
    warning("events have already been set on the road network")
  }
  x$events <- events

  return(x)
}

assign_event_counts_to_segments <- function(segments, event_indices) {
  # Create a frequency table of event occurrences
  event_counts <- table(event_indices)

  # Assign counts to the appropriate segment rows
  segment_indices <- as.integer(names(event_counts))
  segments$count[segment_indices] <- event_counts

  return(segments)
}

#' @export
set_events.road_network <- function(x, events, ...) {
  x <- validate_and_set_events(x, events, "sf")

  return(x)
}

#' @export
set_events.segmented_network <- function(x, events, ...) {
  x <- validate_and_set_events(x, events, "sf")

  # Get the indices of the segments with events
  segment_indices <- sf::st_nearest_feature(events, x$segments)

  # Assign event counts to corresponding segments based on event indices
  x$segments <- assign_event_counts_to_segments(x$segments, segment_indices)

  return(x)
}

#' @export
set_events.spatiotemporal_network <- function(x, events, ...) {
  x <- validate_and_set_events(x, events, "spatiotemporal_events")

  # Get the spatial and temporal indices
  spatial_indices <- sf::st_nearest_feature(events, x$segment_geometries)
  temporal_indices <- find_duration(events, x$segment_durations)
  num_geometries <- nrow(x$segment_geometries)

  # Calculate the segment indices
  segment_indices <- spatial_indices + (temporal_indices - 1) * num_geometries

  # Assign event counts to corresponding segments based on event indices
  x$segments <- assign_event_counts_to_segments(x$segments, segment_indices)

  return(x)
}
