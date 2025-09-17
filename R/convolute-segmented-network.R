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
#' # Apply the convolution to calculate link densities using
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
  # Prepare graph and event data
  line_graph   <- create_line_graph(segmented_network)
  counts       <- segmented_network$segments$count
  source_links <- which(0 < counts)
  n_segments   <- igraph::vcount(line_graph)

  # Initialize densities vector
  densities <- numeric(n_segments)

  # Pre-process data for C++ if using ESD
  if (use_esd) {
    original_graph <- segmented_network$graph

    # Get the degrees of intersections from the original graph
    node_degrees <- igraph::degree(original_graph)
    node_degrees <- as.integer(node_degrees)
    names(node_degrees) <- igraph::V(original_graph)$name

    # Get the adjacency list of the line graph
    adj_list <- igraph::as_adj_list(line_graph, mode = "all")

    # Map line graph vertex IDs to original graph names
    original_edge_names_matrix <- igraph::ends(line_graph,
                                               igraph::E(line_graph))

    # For each row, find the common node in the original graph
    shared_node_ids <- apply(original_edge_names_matrix, 1, function(edge_pair_names) {
      e1_nodes <- igraph::ends(original_graph, edge_pair_names[1])
      e2_nodes <- igraph::ends(original_graph, edge_pair_names[2])
      shared_node <- intersect(e1_nodes, e2_nodes)

      if (0 < length(shared_node)) {
        return(shared_node[1])
      } else {
        return(NA_character_)
      }
    })

    # Look up the degrees using the shared node IDs
    branch_degrees_all_edges <- node_degrees[shared_node_ids]

    # Add this information as a temporary edge attribute for easy lookup
    line_graph <- igraph::set_edge_attr(line_graph,
                                        name = "branch_degree",
                                        value = branch_degrees_all_edges)

    # Create lists of edge weights and corresponding intersection degrees for C++
    edge_data_list <- lapply(seq_len(n_segments), function(u) {
      neighbors <- adj_list[[u]]
      if (length(neighbors) == 0) {
        return(list(weights = numeric(0), distances = numeric(0)))
      }

      # Get the edge IDs between node u and its neighbors
      edge_ids <- igraph::get_edge_ids(line_graph, as.vector(rbind(u, neighbors)))

      # Get edge attributes in batch
      edge_attrs <- igraph::edge_attr(line_graph, index = edge_ids)

      list(weights = edge_attrs$weight, degrees = edge_attrs$branch_degree)
    })

    edge_weights_list   <- lapply(edge_data_list, `[[`, "weights")
    branch_degrees_list <- lapply(edge_data_list, `[[`, "degrees")
  }

  # Calculate and accumulate density contributions from each source link
  for (i in seq_along(source_links)) {
    source_link_index <- source_links[i]

    if (use_esd) {
      # Calculate distances and branch factors simultaneously using C++
      results <- dijkstra_with_branches_cpp(adj            = adj_list,
                                            edge_weights   = edge_weights_list,
                                            branch_degrees = branch_degrees_list,
                                            start_node_r   = source_link_index,
                                            n_nodes        = n_segments)
      distance_row <- results$distances
      branch_row   <- results$branches
    } else {
      # If not using ESD, use the standard igraph distances function
      distance_row <- igraph::distances(line_graph, v = source_link_index)[1, ]
    }

    # Filter for segments within the bandwidth to reduce computation
    target_links <- which(distance_row <= bandwidth)
    if (length(target_links) == 0) next

    # Calculate weights
    weights_i <- kernel(distance_row[target_links] / bandwidth) / bandwidth

    # Apply branch correction if enabled
    if (use_esd) {
      weights_i <- weights_i / branch_row[target_links]
    }

    # Correct for boundary effects for the contribution from this source link
    if (correct_boundary_effects) {
      sum_weights_i <- sum(weights_i)
      if (0 < sum_weights_i) weights_i <- weights_i / sum_weights_i
    }

    # Weight by the event count and add to the final density vector
    densities[target_links] <- densities[target_links] +
                               counts[source_link_index] * weights_i
  }

  # Final normalization of the total density
  sum_densities <- sum(densities)
  if (0 < sum_densities) densities <- densities / sum_densities

  # Store the result in the segmented network object
  segmented_network$segments$density <- densities
  return(segmented_network)
}
