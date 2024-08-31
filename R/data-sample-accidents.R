globalVariables("sample_accidents")

#' Sample accidents data
#'
#' A sample dataset containing information about 10 accidents.
#' The dataset is for demonstration and testing and does not represent
#' real-world events.
#'
#' @format A `sf` object with 10 rows and 4 columns:
#' \describe{
#'   \item{id}{Accident ID}
#'   \item{time}{Time of the accident (in hours)}
#'   \item{weather}{Weather condition at the time of the accident}
#'   \item{severity}{Severity of the accident}
#'   \item{geometry}{Point geometry of the accident location}
#' }
#' @examples
#' # Show information about the accidents
#' sample_accidents
#'
#' # Plot the locations of the accidents
#' plot(sample_roads$geometry)
#' plot(sample_accidents$geometry, pch = 4, col = "red", add = TRUE)
#' @name sample_accidents
"sample_accidents"
