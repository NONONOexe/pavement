#' Find the index of the duration that contains the event time
#'
#' This function find the index of the duration that contains the event time.
#'
#' @param events A spatiotemporal event object.
#' @param durations A duration object.
#' @param ... Additional arguments passed to or from other methods.
#' @return A vector of indices corresponding to the durations that contain
#'   the event times.
#' @export
#' @examples
#' # Create a spatiotemporal event object
#' accidents <- create_spatiotemporal_events(sample_accidents)
#'
#' # Create a duration object
#' durations <- create_durations("1 hour")
#'
#' # Find the duration that contains each accident
#' find_duration(accidents, durations)
find_duration <- function(events, durations, ...) {
  UseMethod("find_duration")
}

#' @export
find_duration.spatiotemporal_events <- function(events, durations, ...) {
  # Check if the durations argument is a `durations` object
  if (!inherits(durations, "durations")) {
    stop("durations must be a `durations` object")
  }

  # Convert event times to `POSIXct` objects
  times <- strptime(events$time, format = attr(events, "time_format"))

  # Find the duration index for each event time
  duration_indices <- vapply(times, function(time) {
    match <- which(time %within% durations$duration)
    if (length(match) == 0) {
      NA_integer_
    } else if (length(match) == 1) {
      match
    } else {
      warning("multiple durations found for time: ", time)
      match[1]
    }
  }, integer(1))

  return(duration_indices)
}
