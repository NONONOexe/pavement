#' Create graph links from source and target nodes
#'
#' This function creates a data frame of graph links from a set of source and
#' target nodes.
#'
#' @param source_nodes A vector of source node IDs.
#' @param target_nodes A vector of target node IDs.
#' @param directed If `FALSE`, the default, the links are undirected.
#'   If `TRUE`, the links are directed.
#' @param unique_links If `TRUE`, the default, the links are unique.
#'   Duplicate links are removed. If `FALSE`, duplicate links are retained.
#' @param link_ids A vector of link IDs.
#' @return A data frame of graph links with columns `from` and `to`.
#' @export
#' @examples
#' # Create source and target nodes
#' source_nodes <- c("jn_000001", "jn_000002", "jn_000002")
#' target_nodes <- c("jn_000002", "jn_000001", "jn_000003")
#'
#' # Create graph links (duplicate links are removed)
#' create_graph_links(source_nodes, target_nodes)
create_graph_links <- function(source_nodes,
                               target_nodes,
                               directed     = FALSE,
                               unique_links = TRUE,
                               link_id      = NULL) {
  # Check if the number of source and target nodes are the same
  if (length(source_nodes) != length(target_nodes)) {
    stop("number of source and target nodes must be the same")
  }
  # Check if the number of link IDs are the same as the number of links
  if (!is.null(link_id) && length(link_id) != length(source_nodes)) {
    stop("number of link IDs must be the same as the number of links")
  }

  # Create links matrix of links
  links_mat <- cbind(source_nodes, target_nodes)

  # Sort the node IDs if undirected
  if (!directed) links_mat <- t(apply(links_mat, 1, sort))

  # Remove duplicate links if unique_links is TRUE
  if (unique_links) links_mat <- unique(links_mat)

  # Create a data frame of links
  graph_links <- data.frame(
    from = links_mat[, 1],
    to   = links_mat[, 2]
  )

  # Add link ID if provided
  if (!is.null(link_id)) graph_links$id <- link_id

  return(graph_links)
}
