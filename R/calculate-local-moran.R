#' Calculate Spatio-temporal Local Moran's I
#'
#' @description
#' Computes the Local Moran's I statistic for each spatio-temporal unit (arixel)
#' to identify clusters and outliers in the event data. The function can handle
#' both `segmented_network` and `spatiotemporal_network` objects.
#'
#' @param network_object A `segmented_network` or `spatiotemporal_network` object
#'   with events assigned via `set_events()`.
#' @param dist_threshold The spatial distance threshold to define neighbors.
#' @param time_threshold The temporal distance threshold (in hours) to define neighbors.
#'
#' @return The input network object with a new component `$moran_results`, which is
#'   a data frame containing the Local Moran's I statistic (`I`), z-scores (`z`),
#'   spatially lagged z-scores (`lagged_z`), and cluster classification (`classification`)
#'   for each arixel.
#'
#' @export
calculate_local_moran <- function(network_object,
                                  dist_threshold = 1,
                                  time_threshold = 2) {

  # --- 1. Package Checks ---
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr is required.")
  if (!requireNamespace("tidyr", quietly = TRUE)) stop("tidyr is required.")
  if (!requireNamespace("Matrix", quietly = TRUE)) stop("Matrix is required.")
  if (!requireNamespace("igraph", quietly = TRUE)) stop("igraph is required.")
  if (!requireNamespace("sf", quietly = TRUE)) stop("sf is required.")

  # --- 2. Preparation: Ensure object compatibility ---
  # Detect object class and extract data from the correct location
  if (inherits(network_object, "spatiotemporal_network")) {
    # Case: spatiotemporal_network object
    segments <- network_object$segment_geometries
    # Ensure graph compatibility
    network_object$graph <- network_object$spatial_graph
  } else {
    # Case: segmented_network object (original behavior)
    segments <- network_object$segments
  }

  events <- network_object$events

  segments <- segments |>
    dplyr::mutate(segment_index = dplyr::row_number())

  # --- 3. Create arixels (spatio-temporal units) ---
  time_points <- 0:23
  n_seg <- nrow(segments)
  n_time <- length(time_points)

  segment_lookup <- dplyr::select(sf::st_drop_geometry(segments), id, segment_index)

  arixels <- tidyr::expand_grid(segment_index = 1:n_seg, time = time_points) |>
    dplyr::left_join(
      sf::st_drop_geometry(events) |>
        dplyr::left_join(segment_lookup, by = c("segment_id" = "id")) |>
        dplyr::count(segment_index, time, name = "x"),
      by = c("segment_index", "time")
    ) |>
    dplyr::mutate(x = tidyr::replace_na(x, 0)) |>
    dplyr::arrange(time, segment_index) |>
    dplyr::mutate(arixel_id = dplyr::row_number())

  # --- 4. Spatial Adjacency Matrix ---
  line_graph <- create_line_graph(network_object)
  dist_mat_space <- igraph::distances(line_graph)
  adj_mat_space <- (dist_mat_space > 0 & dist_mat_space <= dist_threshold)

  # --- 5. Temporal Adjacency Matrix ---
  torus_abs_diff <- function(t1, t2, period = 24) pmin(abs(t1 - t2), period - abs(t1 - t2))
  dist_mat_time <- outer(time_points, time_points, torus_abs_diff)
  adj_mat_time <- (dist_mat_time >= 0 & dist_mat_time <= time_threshold)

  # --- 6. Construct Spatio-temporal Weights Matrix (W) ---
  I_s <- Matrix::Diagonal(n_seg)
  I_t <- Matrix::Diagonal(n_time)
  W_s_component <- Matrix::kronecker(I_t, adj_mat_space)
  W_t_component <- Matrix::kronecker(adj_mat_time, I_s)
  W_st_component <- Matrix::kronecker(adj_mat_time, adj_mat_space)
  W_unstandardized_sum <- W_s_component + W_t_component + W_st_component
  W_unstandardized <- Matrix::Matrix(W_unstandardized_sum > 0, sparse = TRUE)
  Matrix::diag(W_unstandardized) <- 0

  row_sums <- Matrix::rowSums(W_unstandardized)
  W <- Matrix::Diagonal(x = 1 / ifelse(row_sums == 0, 1, row_sums)) %*% W_unstandardized

  # --- 7. Calculate Local Moran's I ---
  x <- arixels$x
  z <- x - mean(x)
  lagged_z <- as.vector(W %*% z)
  local_moran_I <- z * lagged_z

  # --- 8. Format Results ---
  arixels <- arixels |>
    dplyr::left_join(dplyr::select(sf::st_drop_geometry(segments), segment_id = id, segment_index), by = "segment_index") |>
    dplyr::mutate(
      z = z,
      lagged_z = lagged_z,
      I = local_moran_I,
      has_neighbors = (row_sums > 0),
      classification = dplyr::case_when(
        z >= 0 & lagged_z >= 0 & has_neighbors ~ "HH",
        z <  0 & lagged_z <  0 & has_neighbors ~ "LL",
        z <  0 & lagged_z >= 0 & has_neighbors ~ "LH",
        z >= 0 & lagged_z <  0 & has_neighbors ~ "HL",
        TRUE                                  ~ "Not Significant"
      )
    )

  network_object$moran_results <- arixels
  return(network_object)
}

