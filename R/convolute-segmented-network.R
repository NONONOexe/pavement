#' Convolute segmented road network
#'
#' This function convolves a segmented network using a specified kernel
#' function, typically for traffic modeling or network analysis. It computes
#' weights densities based on the distance between links in the network and
#' the number of events assigned to each link. Optionally, it can adjust for
#' branching in the network.
#'
#' @param segmented_network A `segmented_network` object assigned with events.
#' @param kernel A kernel function to use for convolution (default is
#'   Epanechnikov kernel).
#' @param bandwidth Numeric value representing the bandwidth for the kernel
#'   function (default is 3).
#' @param use_esd If `TRUE`, considers branching in the kernel using the
#'   Equal Split Discontinous kernel (ESD). ESD follows the method described in
#'   Okabe et al., accounting for road intersections and ensuring that kernel
#'   weights are correctly distributed across accross branches
#'   (default is `TRUE`).
#' @param correct_boundary_effects If `TRUE`, corrects for boundary effects
#'   by normalizing the kernel weights to account for kernel values outside
#'   the network (default is `TRUE`).
#' @param ... Additional arguments passed to the kernel function.
#' @return The segmented network with updated link densities.
#' @references
#' Okabe, A., Satoh, T., & Sugihara, K. (2009). A kernel density estimation
#' method for networks, its computational method and a GIS-based tool.
#' \emph{International Journal of Geographical Information Science}, 23(1),
#' 7-32. \doi{10.1080/13658810802475491}
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(sample_roads)
#'
#' # Assign sample accidents data
#' road_network <- set_events(road_network, sample_accidents)
#'
#' # Segment the road network
#' segmented_network <- create_segmented_network(
#'   road_network,
#'   segment_length = 0.5
#' )
#'
#' # Check the segmented road network after assigning events
#' segmented_network
#'
#' # Apply the convilution to calculate link densities using
#' # the kernel function
#' convoluted_network <- convolute_segmented_network(segmented_network)
#'
#' # Check the convoluted network with the computed densities
#' convoluted_network
#'
#' # Plot the convoluted network showing the density distribution
#' plot(convoluted_network, mode = "density")
convolute_segmented_network <- function(segmented_network,
                                        kernel = compute_epanechnikov,
                                        bandwidth = 3,
                                        use_esd = TRUE,
                                        correct_boundary_effects = TRUE,
                                        ...) {
  # Create the line graph
  line_graph <- create_line_graph(segmented_network)

  # Get the counts of events assigned to each segment
  counts <- segmented_network$segments$count

  # Identify the links with events
  source_links <- which(0 < counts)

  # Compute the distances from source links
  distance_matrix <- distances(line_graph, v = source_links)

  # Apply the kernel function to calculate weights
  weights <- kernel(distance_matrix / bandwidth, ...) / bandwidth

  # Adjust for branching in the network
  if (use_esd) {
    # Calculate branch adjustments for each source link
    branches <- sapply(source_links, function(source_link) {
      path <- shortest_paths(line_graph, source_link, output = "epath")$epath
      sapply(path, function(link) {
        degrees <- degree(segmented_network$graph)[link$name]
        prod(pmax(degrees - 1, 1))
      })
    })

    # Adjust weights by the branching factors
    weights <- weights / t(branches)
  }

  # Normalize the weights to account for kernel values outside the network
  if (correct_boundary_effects) {
    weights <- weights / rowSums(weights)
  }

  # Multiply the weights by the counts
  weights <- counts[source_links] * weights

  # Calculate the densities for each link
  # by summing and normalizing the weights
  densities <- colSums(weights)
  densities <- densities / sum(densities)

  # Update the segmented network with the computed densities
  segmented_network$segments$density <- densities

  return(segmented_network)
}
