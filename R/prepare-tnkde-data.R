#' Prepare a segmented network for TNKDE
#'
#' Assign events to the nearest road segments and count them.
#' @param segmented_network A segmented network (output of create_segmented_network()).
#' @param events_sf An sf object of events with geometry and time.
#' @return segmented_network with `$events` component and segment-level counts
#' @export
prepare_tnkde_data <- function(segmented_network, events_sf) {
  nearest_indices <- sf::st_nearest_feature(events_sf, segmented_network$segments)
  segment_ids_for_events <- segmented_network$segments$id[nearest_indices]
  events_sf$segment_id <- segment_ids_for_events

  event_counts <- table(events_sf$segment_id)
  segmented_network$segments$count <- 0
  match_indices <- match(names(event_counts), segmented_network$segments$id)
  segmented_network$segments$count[match_indices] <- as.integer(event_counts)

  segmented_network$events <- events_sf
  return(segmented_network)
}

#' Set events in segmented network (pipe-friendly)
#' @export
set_events <- function(segmented_network, events_sf) {
  prepare_tnkde_data(segmented_network, events_sf)
}
