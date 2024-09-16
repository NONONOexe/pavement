#' Create a spatiotemporal event collection
#'
#' This function creates a spatiotemporal event collection object from
#' a given `sf` object, allowing spatial and temporal data to be
#' handled together.
#'
#' @param x A `sf` object representing the spatial data.
#' @param ... Additional arguments passed to or from other methods.
#' @return An `sf` object with class `spatiotemporal_event` added,
#'   representing a spatiotemporal event collection.
#' @name spatiotemporal_event
#' @aliases create_spatiotemporal_event
#' @export
#' @examples
#' # Simple feature collection object representing accidents
#' sample_accidents
#'
#' # Create a spatiotemporal event collection
#' create_spatiotemporal_event(sample_accidents)
create_spatiotemporal_event <- function(x, ...) {
  UseMethod("create_spatiotemporal_event")
}

#' @param time_column_name A character string specifying the column name
#'   in `x` that contains time-related data. Defaults to `"time"`
#' @param time_format A character string specifying the format of
#'   the time data in the `time_column_name`. For example, you can
#'   use formats like `"%Y-%m-%d"` for dates or `"%H:%M:%S"` for time.
#'   Defaults to `"%H"`.
#' @rdname spatiotemporal_event
#' @export
create_spatiotemporal_event.sf <- function(x,
                                           time_column_name = "time",
                                           time_format = "%H",
                                           ...) {
  attributes(x)$class <- c("spatiotemporal_event", "sf", "data.frame")
  attr(x, "time_column") <- time_column_name
  attr(x, "time_format") <- time_format

  return(x)
}

#' Print a spatiotemporal event collection
#'
#' This function prints a summary of a spatiotemporal event collection object.
#'
#' @param x A `spatiotemporal_event` object.
#' @param ... Additional arguments passed to or from other methods.
#' @return The `spatiotemporal_event` object, invisibly.
#' @export
#' @examples
#' spatiotemporal_events <- create_spatiotemporal_event(sample_accidents)
#' print(spatiotemporal_events)
print.spatiotemporal_event <- function(x, ...) {
  cat("Spatiotemporal event collection with",
      nrow(x), "events and", ncol(x) - 2, "fields", fill = TRUE)
  cat("Geometry type:", as.character(unique(st_geometry_type(x))), fill = TRUE)
  cat("Time column:  ", attr(x, "time_column"), fill = TRUE)
  cat("Time format:  ", attr(x, "time_format"), fill = TRUE)
  cat("Data:", fill = TRUE)
  print(as.data.frame(x)[1:5, ])
  if (5 < nrow(x)) cat("...", nrow(x) - 5, "more events\n")

  return(invisible(x))
}
