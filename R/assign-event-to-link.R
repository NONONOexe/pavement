#' Assign events to the nearest link
#'
#' This function assigns events to the nearest link in a segmented road
#' network.
#'
#' @param segmented_network A `segmented_network` object, which contains
#'   a list of segmented links and nodes, representing the segmented road
#'   network.
#' @param events A `sf` object representing events, such as traffic accidents,
#'   with location information.
#' @return A `segmented_network` object with events assigned to links. Each
#'   link will have a `count` attribute indicating the number of events
#'   assigned to it.
#' @export
#' @examples
#' # Create the segmented road network
#' road_network <- create_road_network(sample_roads)
#' segmented_network <- create_segmented_network(road_network)
#'
#' # Assign accidents to the nearest link
#' segmented_network <- assign_event_to_link(
#'   segmented_network,
#'   sample_accidents
#' )
#'
#' # Plot the segmented road network with events
#' plot(segmented_network, mode = "event")
assign_event_to_link <- function(segmented_network, events) {
  # Add events to `segment_network` object
  segmented_network$events <- events

  # Assign the event counts to the corresponding links
  event_counts <- table(st_nearest_feature(events, segmented_network$links))
  link_indices <- as.integer(names(event_counts))
  segmented_network$links$count[link_indices] <- event_counts

  return(segmented_network)
}
