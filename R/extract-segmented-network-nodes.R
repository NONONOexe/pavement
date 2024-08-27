#' Extract nodes of segmented network from a road network
#'
#' This function extracts nodes at regular intervals along each link in
#' a road network
#'
#' @param road_network A `road_network` object created with `create_network()`.
#' @param segment_length The length of each segment to sample along the links.
#' @return An `sf` object with the sampled points.
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(demo_roads)
#'
#' # Extract nodes with a segment length of 1
#' extract_segmented_network_nodes(road_network, 1)
extract_segmented_network_nodes <- function(road_network, segment_length) {
  UseMethod("extract_segmented_network_nodes")
}

#' @export
extract_segmented_network_nodes.road_network <- function(road_network, segment_length) {
  # Sample points along each link geometry
  sampled_geometries <- mapply(
    function(link, id, road) {
      link_length <- st_length(link)
      num_segments <- round(link_length / segment_length)
      sampling_points <- seq(0, 1, length.out = num_segments + 1)
      sampling_points <- sampling_points[-c(1, length(sampling_points))]
      sampled_points <- st_line_sample(link, sample = sampling_points)

      data.frame(
        parent_link = id,
        parent_road = road,
        geometry    = st_cast(sampled_points, "POINT")
      )
    },
    road_network$links$geometry,
    road_network$links$id,
    road_network$links$parent_road,
    SIMPLIFY = FALSE
  )

  # Combine the list of data frames into a single `sf` object
  sampled_nodes <- do.call(rbind, sampled_geometries)
  sampled_nodes <- st_as_sf(sampled_nodes, agr = "constant")

  # Remove duplicated nodes
  sampled_nodes <- sampled_nodes[!duplicated(sampled_nodes$geometry), ]

  # Assign unique IDs to nodes
  sampled_nodes$id <- sprintf("sn_%08x", seq_along(sampled_nodes$parent_link))
  rownames(sampled_nodes) <- sampled_nodes$id

  return(sampled_nodes[c("id", "parent_link", "parent_road")])
}
