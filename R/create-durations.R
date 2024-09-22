#' Create durations
#'
#' This function creates a data frame of durations.
#'
#' @param duration_length The length of each duration.
#' @param ... Additional arguments passed to or from other methods.
#' @return A `durations` object.
#' @name durations
#' @aliases create_durations
#' @export
#' @examples
#' # Create durations of 1 hour
#' create_durations("1 hour")
#'
#' # Create durations of 30 minutes
#' create_durations("30 minutes")
create_durations <- function(duration_length, ...) {
  UseMethod("create_durations")
}

#' @export
create_durations.character <- function(duration_length, ...) {
  # Replace "minutes" with "min"
  duration_length <- gsub("minutes", "min", duration_length)

  # Set the start and end time
  start_time <- as.POSIXct("00:00", format = "%H:%M")
  end_time <- as.POSIXct("24:00", format = "%H:%M")

  # Create a sequence of times
  time_seq <- seq(start_time, end_time, by = duration_length)
  time_slices <- interval(head(time_seq, -1), tail(time_seq, -1) - 1)

  # Create a `durations` object
  durations <- data.frame(
    id = sprintf("ti_%04x", seq_along(time_slices)),
    duration = time_slices
  )
  class(durations) <- c("durations", "data.frame")

  return(durations)
}
