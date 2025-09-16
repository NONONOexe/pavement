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
  split_linestrings <- sf::st_collection_extract(
    suppressMessages(st_split(roads, nodes)), "LINESTRING"
  )

  # Get all start and end points of the split linestrings
  start_points <- lwgeom::st_startpoint(split_linestrings)
  end_points <- lwgeom::st_endpoint(split_linestrings)

  # Find the index of the matching node for each point
  from_indices <- sf::st_intersects(start_points, nodes)
  to_indices <- sf::st_intersects(end_points, nodes)

  # Convert the list of indices to a numeric vector
  from_indices_vec <- vapply(
    from_indices,
    function(i) if (length(i) == 0) NA_integer_ else i[1],
    integer(1)
  )
  to_indices_vec <- vapply(
    to_indices,
    function(i) if (length(i) == 0) NA_integer_ else i[1],
    integer(1)
  )

  # Retrieve the node IDs using the indices
  from <- nodes$id[from_indices_vec]
  to   <- nodes$id[to_indices_vec]

  # Create a new sf object representing the road network links
  network_links <- sf::st_sf(
    id          = sprintf("lk_%06x", seq_along(split_linestrings$id)),
    from        = from,
    to          = to,
    parent_road = split_linestrings$id,
    geometry    = split_linestrings$geometry
  )

  return(network_links)
}
