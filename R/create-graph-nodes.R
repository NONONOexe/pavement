#' Create a data frame of nodes for a graph
#'
#' This function creates a data frame of nodes for a graph from a set of node
#' IDs and geometries.
#'
#' @param node_ids A vector of node IDs.
#' @param node_geometries A `sfc_POINT` object containing node geometries.
#' @return A data frame of nodes with columns `id`, `x`, and `y`.
#' @export
#' @examples
#' library(sf)
#'
#' # Create node IDs and geometries
#' node_ids <- c("jn_000001", "jn_000002", "jn_000003")
#'
#' # Create some node geometries
#' node_geometries <- st_sfc(
#'   st_point(c(0, 1)),
#'   st_point(c(1, 0)),
#'   st_point(c(2, 1))
#' )
#'
#' # Create a data frame of nodes
#' create_graph_nodes(node_ids, node_geometries)
create_graph_nodes <- function(node_ids, node_geometries) {
  # Extract node coordinates
  coordinates <- st_coordinates(node_geometries)

  # Create a data frame of nodes
  graph_nodes <- data.frame(
    id = node_ids,
    x  = coordinates[, 1],
    y  = coordinates[, 2]
  )

  return(graph_nodes)
}
