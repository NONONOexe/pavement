#' Convolute a spatiotemporal network to perform TNKDE
#'
#' @description
#' This function performs Temporal Network Kernel Density Estimation (TNKDE) on a
#' spatiotemporal network object. It calculates density values across the network's
#' segments for a series of time points.
#'
#' @param segmented_network A spatiotemporal network object, typically the output of
#'   `create_spatiotemporal_network()` followed by `set_events()`.
#' @param kernel_space The spatial kernel function (default: `compute_epanechnikov`).
#' @param kernel_time The temporal kernel function (default: `compute_epanechnikov`).
#' @param bandwidth_space The spatial bandwidth (in the network's distance units).
#' @param bandwidth_time The temporal bandwidth (in hours).
#' @param time_points A numeric vector of time points (e.g., hours 0:23) at which to
#'   estimate the density.
#' @param use_esd If `TRUE` (default), uses the Equal Split Discontinuous (ESD) kernel
#'   for spatial smoothing to account for network intersections.
#' @param correct_boundary_effects If `TRUE` (default), corrects for boundary effects
#'   by normalizing the kernel weights from each source to sum to 1.
#' @return The input network object with the `$segments` component updated to an `sf`
#'   data frame of spatial segments, now containing new columns (`density_t_0`,
#'   `density_t_1`, etc.) with the calculated density values. The total density
#'   over all segments and time points is normalized to sum to 1.
#' @export
convolute_spatiotemporal_network <- function(segmented_network,
                                             kernel_space = compute_epanechnikov,
                                             kernel_time  = compute_epanechnikov,
                                             bandwidth_space = 250,
                                             bandwidth_time  = 2.5,
                                             time_points = 0:23,
                                             use_esd = TRUE,
                                             correct_boundary_effects = TRUE) {

  # --- 1. Preparation and Input Checks ---
  if (inherits(segmented_network, "spatiotemporal_network")) {
    segmented_network$graph <- segmented_network$spatial_graph
  }
  events <- segmented_network$events
  st_segments <- segmented_network$segments
  if(is.null(st_segments) || nrow(st_segments) == 0) stop("No segments found in the network object.")
  if(is.null(events) || nrow(events) == 0) stop("No events found. Please run set_events() first.")
  if(!"time" %in% names(events)) stop("The events data frame must have a 'time' column.")
  if(!"st_segment_index" %in% names(events)) stop("The events data frame is missing 'st_segment_index'. Please ensure you are using the correct version of set_events().")

  line_graph <- create_line_graph(segmented_network)
  num_spatial_segments <- nrow(segmented_network$segment_geometries)

  # --- 2. Pre-processing for C++ function (if use_esd is TRUE) ---
  if (use_esd) {
    original_graph <- segmented_network$graph
    node_degrees <- igraph::degree(original_graph)
    names(node_degrees) <- igraph::V(original_graph)$name
    adj_list <- igraph::as_adj_list(line_graph, mode = "all")
    original_edge_names_matrix <- igraph::ends(line_graph, igraph::E(line_graph))
    shared_node_ids <- apply(original_edge_names_matrix, 1, function(edge_pair_names) {
      e1_nodes <- igraph::ends(original_graph, edge_pair_names[1])
      e2_nodes <- igraph::ends(original_graph, edge_pair_names[2])
      shared_node <- intersect(e1_nodes, e2_nodes)
      if (length(shared_node) > 0) return(shared_node[1]) else return(NA_character_)
    })
    branch_degrees_all_edges <- node_degrees[shared_node_ids]
    branch_degrees_all_edges[is.na(branch_degrees_all_edges)] <- 2
    line_graph <- igraph::set_edge_attr(line_graph, "branch_degree", value = branch_degrees_all_edges)
    edge_data_list <- lapply(seq_len(num_spatial_segments), function(u) {
      neighbors <- adj_list[[u]]
      if (length(neighbors) == 0) return(list(weights = numeric(0), degrees = integer(0)))
      edge_ids <- igraph::get_edge_ids(line_graph, as.vector(rbind(u, neighbors)))
      edge_attrs <- igraph::edge_attr(line_graph, index = edge_ids)
      list(weights = edge_attrs$weight, degrees = as.integer(edge_attrs$branch_degree))
    })
    edge_weights_list   <- lapply(edge_data_list, `[[`, "weights")
    branch_degrees_list <- lapply(edge_data_list, `[[`, "degrees")
  }

  # --- 3. TNKDE Calculation ---
  torus_abs_diff <- function(t_eval, t_obs, period = 24) { d <- abs(t_eval - t_obs); pmin(d, period - d) }
  density_list <- vector("list", length(time_points))
  names(density_list) <- paste0("density_t_", time_points)

  # Pre-calculate the spatial segment index for each event
  event_spatial_indices <- events$st_segment_index %% num_spatial_segments
  event_spatial_indices[event_spatial_indices == 0] <- num_spatial_segments

  # Loop over each target time point
  for (t in time_points) {
    density_t <- numeric(num_spatial_segments)

    # Calculate temporal weights for all events relative to the current time 't'
    dt <- torus_abs_diff(t, events$time)
    # The kernel value is correctly scaled by the bandwidth, as per the formula.
    w_time <- kernel_time(dt / bandwidth_time) / bandwidth_time

    # Filter for events that have a temporal influence (w_time > 0)
    active_events_indices <- which(w_time > 0)

    # Loop over each active event 'i'
    for (i in active_events_indices) {
      source_link_index <- event_spatial_indices[i]
      temporal_weight <- w_time[i]

      # Perform spatial smoothing
      if (use_esd) {
        results <- dijkstra_with_branches_cpp(adj = adj_list, edge_weights = edge_weights_list,
                                              branch_degrees = branch_degrees_list,
                                              start_node_r = source_link_index,
                                              n_nodes = num_spatial_segments)
        distance_row <- results$distances
        branch_row <- results$branches
      } else {
        distance_row <- igraph::distances(line_graph, v = source_link_index)[1, ]
      }

      target_links <- which(distance_row <= bandwidth_space)
      if (length(target_links) == 0) next

      # Apply spatial kernel, correctly scaled by the bandwidth
      weights_s <- kernel_space(distance_row[target_links] / bandwidth_space) / bandwidth_space

      if (use_esd) {
        branch_row[target_links][branch_row[target_links] < 1] <- 1
        weights_s <- weights_s / branch_row[target_links]
      }
      if (correct_boundary_effects) {
        sum_weights_s <- sum(weights_s)
        if (sum_weights_s > 0) weights_s <- weights_s / sum_weights_s
      }

      # Add the contribution from this event, weighted by its temporal influence
      density_t[target_links] <- density_t[target_links] + temporal_weight * weights_s
    }

    density_list[[paste0("density_t_", t)]] <- density_t
  }

  # --- 4. Format Results and Final Normalization ---
  density_matrix <- do.call(cbind, density_list)

  # Normalize so the sum of all densities over all segments and times equals 1
  total_sum <- sum(density_matrix)
  if (total_sum > 0) {
    density_matrix <- density_matrix / total_sum
  }

  final_segments <- segmented_network$segment_geometries
  for(i in seq_along(density_list)) {
    final_segments[[names(density_list)[i]]] <- density_matrix[, i]
  }

  segmented_network$segments <- final_segments

  return(segmented_network)
}
