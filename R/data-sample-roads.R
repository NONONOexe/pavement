globalVariables("sample_roads")

#' Sample roads data
#'
#' A sample dataset representing simple roads.
#' It intended for demonstration and testing and does not represent
#' real-world roads.
#'
#' @format A `sf` linestring object with 6 rows and 2 columns:
#' \describe{
#'   \item{id}{Road ID}
#'   \item{layer}{Layer of the road (indicates a road on an elevated
#'     structure such as a bridge, tunnel, or highway)}
#'   \item{geometry}{Linestring geometry of the road}
#' }
#' @examples
#' # Show information about the roads
#' sample_roads
#'
#' # Shape of the roads
#' plot(sample_roads$geometry)
#' @name sample_roads
"sample_roads"
