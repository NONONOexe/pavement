#' Extract road network links
#'
#' This function extracts the road network links from a set of road geometries.
#' It splits the road geometries at the nodes and creates a new sf object
#' representing the road network links.
#'
#' @param roads A linestring object representing the roads.
#' @param nodes A point object representing the road network nodes.
#' @return A linestring object representing the road network links.
#' @seealso To create the nodes, use the [extract_road_network_nodes()]
#' @export
extract_road_network_links <- function(roads, nodes) {
  # Split the road geometries at the node geometries
  split_linestrings <- st_collection_extract(
    suppressMessages(st_split(roads, nodes)), "LINESTRING"
  )

  # Get the node IDs for the start and end points of each link
  from <- sapply(st_startpoint(split_linestrings), function(point) {
    nodes[which(sapply(nodes$geometry, identical, point)), ]$id
  })
  to <- sapply(st_endpoint(split_linestrings), function(point) {
    nodes[which(sapply(nodes$geometry, identical, point)), ]$id
  })

  # Create a new sf object representing the road network links
  network_links <- st_sf(
    id          = sprintf("lk_%06x", seq_along(split_linestrings$id)),
    from        = from,
    to          = to,
    parent_road = split_linestrings$id,
    geometry    = split_linestrings$geometry
  )
  rownames(network_links) <- network_links$id

  return(network_links)
}
