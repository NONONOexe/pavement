#' Set events on a space.
#'
#' This function sets events on a space.
#'
#' @param x A `road_network` or `segmented_network` object.
#' @param events A `sf` object representing events.
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

#' @rdname set_events
#' @export
set_events.road_network <- function(x, events, ...) {
  x <- validate_and_set_events(x, events)

  return(x)
}

#' @rdname set_events
#' @export
set_events.segmented_network <- function(x, events, ...) {
  x <- validate_and_set_events(x, events)

  # Count events on each link
  event_counts <- table(st_nearest_feature(events, x$links))
  # Get the indices of the links with events
  link_indices <- as.integer(names(event_counts))
  # Update the count of events of each link
  x$links$count[link_indices] <- event_counts

  return(x)
}

validate_and_set_events <- function(x, events) {
  if (!inherits(events, "sf")) {
    stop("events must be a `sf` object")
  }
  if ("events" %in% names(x)) {
    warning("events have already been set on the road network")
  }
  x$events <- events

  return(x)
}
