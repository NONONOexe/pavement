#' Calculate spatio-temporal local Moran's I
#'
#' @description
#' Computes Local Moran's I for each spatio-temporal unit (arixel) while preserving sf geometry.
#' Handles both segmented_network and spatiotemporal_network objects.
#'
#' @param network_object A segmented_network or spatiotemporal_network with events assigned.
#' @param dist_threshold Spatial distance threshold for neighbors.
#' @param time_threshold Temporal distance threshold (in hours) for neighbors.
#' @return The network object with $moran_results containing I, z, lagged_z, and cluster classification.
#' @export
calculate_local_moran <- function(network_object,
                                  dist_threshold = 1,
                                  time_threshold = 2) {

  # Object compatibility
  if (inherits(network_object, "spatiotemporal_network")) {
    segments <- network_object$segment_geometries
    network_object$graph <- network_object$spatial_graph
  } else {
    segments <- network_object$segments
  }
  events <- network_object$events

  # Add segment index
  segments$segment_index <- seq_len(nrow(segments))

  # Create arixels (spatio-temporal units)
  time_points <- 0:23
  n_seg <- nrow(segments)
  n_time <- length(time_points)
  arixels <- expand.grid(segment_index = 1:n_seg, time = time_points, stringsAsFactors = FALSE)
  arixels$x <- 0  # initialize counts

  # Assign counts
  events_no_geom <- events
  sf::st_geometry(events_no_geom) <- NULL
  segment_lookup <- segments[, c("id", "segment_index")]
  sf::st_geometry(segment_lookup) <- NULL

  # Map segment_id to segment_index
  events_no_geom$segment_index <- segment_lookup$segment_index[match(events_no_geom$segment_id, segment_lookup$id)]

  # Count events per arixel
  tab <- table(events_no_geom$segment_index, events_no_geom$time)
  seg_idx <- as.integer(rownames(tab))
  times <- as.integer(colnames(tab))
  for (i in seq_along(seg_idx)) {
    for (j in seq_along(times)) {
      arixel_idx <- which(arixels$segment_index == seg_idx[i] & arixels$time == times[j])
      arixels$x[arixel_idx] <- tab[i, j]
    }
  }

  # Assign arixel_id
  arixels$arixel_id <- seq_len(nrow(arixels))

  # Spatial and temporal adjacency
  line_graph <- create_line_graph(network_object)
  dist_mat_space <- igraph::distances(line_graph)
  adj_mat_space <- (dist_mat_space > 0 & dist_mat_space <= dist_threshold)

  torus_abs_diff <- function(t1, t2, period = 24) pmin(abs(t1 - t2), period - abs(t1 - t2))
  dist_mat_time <- outer(time_points, time_points, torus_abs_diff)
  adj_mat_time <- (dist_mat_time >= 0 & dist_mat_time <= time_threshold)

  # Spatio-temporal weights
  I_s <- Matrix::Diagonal(n_seg)
  I_t <- Matrix::Diagonal(n_time)
  W_s <- Matrix::kronecker(I_t, adj_mat_space)
  W_t <- Matrix::kronecker(adj_mat_time, I_s)
  W_st <- Matrix::kronecker(adj_mat_time, adj_mat_space)
  W_unstd <- Matrix::Matrix((W_s + W_t + W_st) > 0, sparse = TRUE)
  Matrix::diag(W_unstd) <- 0
  row_sums <- Matrix::rowSums(W_unstd)
  W <- Matrix::Diagonal(x = 1 / ifelse(row_sums == 0, 1, row_sums)) %*% W_unstd

  # Local Moran's I
  x_vals <- arixels$x
  z <- x_vals - mean(x_vals)
  lagged_z <- as.vector(W %*% z)
  local_I <- z * lagged_z

  segments_no_geom <- segments
  sf::st_geometry(segments_no_geom) <- NULL
  arixels$segment_id <- segments_no_geom$id[arixels$segment_index]

  arixels$z <- z
  arixels$lagged_z <- lagged_z
  arixels$I <- local_I
  arixels$has_neighbors <- (row_sums > 0)

  # Classify clusters
  arixels$classification <- "Not Significant"
  arixels$classification[z >= 0 & lagged_z >= 0 & arixels$has_neighbors] <- "HH"
  arixels$classification[z <  0 & lagged_z <  0 & arixels$has_neighbors] <- "LL"
  arixels$classification[z <  0 & lagged_z >=0 & arixels$has_neighbors] <- "LH"
  arixels$classification[z >=0 & lagged_z <  0 & arixels$has_neighbors] <- "HL"

  network_object$moran_results <- arixels
  return(network_object)
}
