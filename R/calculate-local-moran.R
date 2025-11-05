#' Calculate spatio-temporal local Moran's I
#'
#' @description
#' Computes the Local Moran's I statistic for each spatiotemporal unit (spatiotemporal segment)
#' using a memory-efficient, iterative approach. This function can handle
#' both `segmented_network` and `spatiotemporal_network` objects.
#'
#' @param network_object A `segmented_network` or `spatiotemporal_network` object
#'   with events assigned via `set_events()`.
#' @param dist_threshold The spatial distance threshold to define neighbors.
#' @param time_threshold The temporal distance threshold (in hours) to define neighbors.
#'
#' @return The input network object with a new component `$moran_results`. This is
#'   a data frame containing the Local Moran's I statistic (`I`), z-scores (`z`),
#'   spatially lagged z-scores (`lagged_z`), and cluster classification (`classification`)
#'   for each spatiotemporal segment.
#'
#' @export
#'
#' @examples
#' # First, create a network and assign events
#' network_with_events <- sample_roads |>
#'   create_road_network() |>
#'   create_spatiotemporal_network(spatial_length = 0.5) |>
#'   set_events(sample_accidents)
#'
#' # Then, calculate Local Moran's I
#' moran_result <- calculate_local_moran(
#'   network_with_events,
#'   dist_threshold = 1,
#'   time_threshold = 2
#' )
#'
#' # View the results
#' head(moran_result$moran_results)
#'
#' # Plot the results
#' plot_local_moran(moran_result, snapshot_time = 12)
#' plot_local_moran(moran_result, plot_3d = TRUE)

calculate_local_moran <- function(network_object,
                                  dist_threshold = 1,
                                  time_threshold = 2) {

  # Preparation and spatiotemporal segment creation
  if (inherits(network_object, "spatiotemporal_network")) {
    segments <- network_object$segment_geometries
    network_object$graph <- network_object$spatial_graph
  } else {
    segments <- network_object$segments
  }
  events <- network_object$events
  segments$segment_index <- seq_len(nrow(segments))

  time_points <- 0:23
  n_seg <- nrow(segments)
  n_time <- length(time_points)
  N <- n_seg * n_time

  # Build spatiotemporal segments grid in time-major order
  spatiotemporal_segments <- expand.grid(
    segment_index = seq_len(n_seg),
    time = time_points,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  spatiotemporal_segments <- spatiotemporal_segments[order(spatiotemporal_segments$time, spatiotemporal_segments$segment_index), ]
  spatiotemporal_segments$spatiotemporal_segment_id <- seq_len(nrow(spatiotemporal_segments))

  # Count events per spatiotemporal segment
  spatiotemporal_segments$x <- 0L
  if (!is.null(events) && nrow(events) > 0) {
    events_no_geom <- events
    sf::st_geometry(events_no_geom) <- NULL
    segment_lookup <- segments[, c("id", "segment_index")]
    sf::st_geometry(segment_lookup) <- NULL
    events_no_geom$segment_index <- segment_lookup$segment_index[
      match(events_no_geom$segment_id, segment_lookup$id)
    ]
    ttab <- table(events_no_geom$segment_index, events_no_geom$time)
    if (length(ttab) > 0) {
      rn <- as.integer(rownames(ttab))
      cn <- as.integer(colnames(ttab))
      for (ri in seq_along(rn)) {
        for (cj in seq_along(cn)) {
          cnt <- ttab[ri, cj]
          if (cnt == 0) next
          seg_idx <- rn[ri]
          tm <- cn[cj]
          ar_idx <- (which(time_points == tm) - 1) * n_seg + seg_idx
          spatiotemporal_segments$x[ar_idx] <- cnt
        }
      }
    }
  }

  # Precompute neighbor lists
  line_graph <- create_line_graph(network_object)
  dist_mat_space <- igraph::distances(line_graph)  # n_seg x n_seg matrix
  torus_abs_diff <- function(a, b, period = 24) pmin(abs(a - b), period - abs(a - b))

  x_vals <- spatiotemporal_segments$x
  z <- x_vals - mean(x_vals)

  # Spatial neighbors (list of segment indices)
  spatial_neighbors_list <- vector("list", n_seg)
  for (s in seq_len(n_seg)) {
    drow <- dist_mat_space[s, ]
    spatial_neighbors_list[[s]] <- which(drow > 0 & drow <= dist_threshold)
  }

  # Temporal neighbors (list of time indices)
  temporal_neighbors_list <- vector("list", n_time)
  for (ti in seq_len(n_time)) {
    tval <- time_points[ti]
    diffs <- torus_abs_diff(time_points, tval)
    temporal_neighbors_list[[ti]] <- which(diffs <= time_threshold)
  }

  # Compute lagged values
  lagged_z <- rep(NA_real_, N)  # default NA
  row_has_neighbors <- logical(N)

  for (time_idx in seq_len(n_time)) {
    base_row <- (time_idx - 1) * n_seg
    t_nbrs <- temporal_neighbors_list[[time_idx]]

    for (seg_i in seq_len(n_seg)) {
      row_index <- base_row + seg_i
      seg_spat_nbrs <- spatial_neighbors_list[[seg_i]]

      spatial_same_time_idx <- if (length(seg_spat_nbrs) > 0) {
        base_row + seg_spat_nbrs
      } else integer(0)

      tn_other <- t_nbrs[t_nbrs != time_idx]
      temporal_only_idx <- if (length(tn_other) > 0) {
        (tn_other - 1) * n_seg + seg_i
      } else integer(0)

      spatio_temporal_idx <- if (length(seg_spat_nbrs) > 0 && length(tn_other) > 0) {
        unlist(lapply(tn_other, function(tj) (tj - 1) * n_seg + seg_spat_nbrs),
               use.names = FALSE)
      } else integer(0)

      neigh_idx <- c(spatial_same_time_idx, temporal_only_idx, spatio_temporal_idx)

      if (length(neigh_idx) > 0) {
        row_has_neighbors[row_index] <- TRUE
        lagged_z[row_index] <- sum(z[neigh_idx]) / length(neigh_idx)
      }
    }
  }

  local_I <- z * lagged_z

  # Results
  segments_no_geom <- segments
  sf::st_geometry(segments_no_geom) <- NULL
  spatiotemporal_segments$segment_id <- segments_no_geom$id[spatiotemporal_segments$segment_index]

  spatiotemporal_segments$z <- z
  spatiotemporal_segments$lagged_z <- lagged_z
  spatiotemporal_segments$I <- local_I
  spatiotemporal_segments$has_neighbors <- row_has_neighbors

  spatiotemporal_segments$classification <- "Not Significant"
  spatiotemporal_segments$classification[z >= 0 & lagged_z >= 0 & spatiotemporal_segments$has_neighbors] <- "HH"
  spatiotemporal_segments$classification[z <  0 & lagged_z <  0 & spatiotemporal_segments$has_neighbors] <- "LL"
  spatiotemporal_segments$classification[z <  0 & lagged_z >= 0 & spatiotemporal_segments$has_neighbors] <- "LH"
  spatiotemporal_segments$classification[z >= 0 & lagged_z <  0 & spatiotemporal_segments$has_neighbors] <- "HL"

  network_object$moran_results <- spatiotemporal_segments
  return(network_object)
}
