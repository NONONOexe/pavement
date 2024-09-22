#' Create a spatiotemporal event collection
#'
#' This function creates a spatiotemporal event collection object from
#' a given `sf` object, allowing spatial and temporal data to be
#' handled together.
#'
#' @param x A `sf` object representing the spatial data.
#' @param ... Additional arguments passed to or from other methods.
#' @return An `sf` object with class `spatiotemporal_events` added,
#'   representing a spatiotemporal event collection.
#' @name spatiotemporal_events
#' @aliases create_spatiotemporal_events
#' @export
#' @examples
#' # Simple feature collection object representing accidents
#' sample_accidents
#'
#' # Create a spatiotemporal event collection
#' create_spatiotemporal_events(sample_accidents)
create_spatiotemporal_events <- function(x, ...) {
  UseMethod("create_spatiotemporal_events")
}

#' @param time_column_name A character string specifying the column name
#'   in `x` that contains time-related data. Defaults to `"time"`
#' @param time_format A character string specifying the format of
#'   the time data in the `time_column_name`. For example, you can
#'   use formats like `"%Y-%m-%d"` for dates or `"%H:%M:%S"` for time.
#'   Defaults to `"%H"`.
#' @rdname spatiotemporal_events
#' @export
create_spatiotemporal_events.sf <- function(x,
                                           time_column_name = "time",
                                           time_format = "%H",
                                           ...) {
  attributes(x)$class <- c("spatiotemporal_events", "sf", "data.frame")
  attr(x, "time_column") <- time_column_name
  attr(x, "time_format") <- time_format

  return(x)
}

#' @export
print.spatiotemporal_events <- function(x, ...) {
  cat("Spatiotemporal event collection with",
      nrow(x), "events and", ncol(x) - 2, "fields", fill = TRUE)
  cat("Geometry type:", as.character(unique(st_geometry_type(x))), fill = TRUE)
  cat("Time column:  ", attr(x, "time_column"), fill = TRUE)
  cat("Time format:  ", attr(x, "time_format"), fill = TRUE)
  cat("Data:", fill = TRUE)
  print(as.data.frame(x)[1:5, ])
  if (5 < nrow(x)) cat("...", nrow(x) - 5, "more events", fill = TRUE)

  return(invisible(x))
}
