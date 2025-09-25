
#' @export
calculate_local_moran <- function(segmented_network,
                                  dist_threshold = 1, 
                                  time_threshold = 2) { 
  
  # --- パッケージ確認 ---
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr is required.")
  if (!requireNamespace("tidyr", quietly = TRUE)) stop("tidyr is required.")
  if (!requireNamespace("Matrix", quietly = TRUE)) stop("Matrix is required.")
  if (!requireNamespace("igraph", quietly = TRUE)) stop("igraph is required.")
  if (!requireNamespace("sf", quietly = TRUE)) stop("sf is required.")
  
  
  events <- segmented_network$events
  segments <- segmented_network$segments |>
    dplyr::mutate(segment_index = dplyr::row_number())
  
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
  
  # --- 空間隣接行列 ---
  line_graph <- create_line_graph(segmented_network)
  dist_mat_space <- igraph::distances(line_graph)
  adj_mat_space <- (dist_mat_space > 0 & dist_mat_space <= dist_threshold)
  
  # --- 時間隣接行列 ---
  torus_abs_diff <- function(t1, t2, period = 24) pmin(abs(t1 - t2), period - abs(t1 - t2))
  dist_mat_time <- outer(time_points, time_points, torus_abs_diff)
  adj_mat_time <- (dist_mat_time >= 0 & dist_mat_time <= time_threshold)
  
  # --- Wの構築 ---
  I_s <- Matrix::Diagonal(n_seg)
  I_t <- Matrix::Diagonal(n_time)
  W_s_component <- Matrix::kronecker(I_t, adj_mat_space)
  W_t_component <- Matrix::kronecker(adj_mat_time, I_s)
  W_st_component <- Matrix::kronecker(adj_mat_time, adj_mat_space)
  W_unstandardized_sum <- W_s_component + W_t_component + W_st_component
  W_unstandardized <- sign(W_unstandardized_sum)
  Matrix::diag(W_unstandardized) <- 0
  
  row_sums <- Matrix::rowSums(W_unstandardized)
  W <- Matrix::Diagonal(x = 1 / ifelse(row_sums == 0, 1, row_sums)) %*% W_unstandardized
  x <- arixels$x
  z <- x - mean(x)
  lagged_z <- as.vector(W %*% z)
  local_moran_I <- z * lagged_z
  
  
  arixels <- arixels |>
    dplyr::left_join(dplyr::select(sf::st_drop_geometry(segments), segment_id = id, segment_index), by = "segment_index") |>
    dplyr::mutate(
      z = z, lagged_z = lagged_z, I = local_moran_I,
      has_neighbors = (row_sums > 0),
      classification = dplyr::case_when(
        z >= 0 & lagged_z > 0 ~ "HH",
        z < 0 & lagged_z < 0 ~ "LL",
        z < 0 & lagged_z > 0 ~ "LH",
        z >= 0 & lagged_z < 0 ~ "HL",
        TRUE ~ "LL"
      )
    )
  
  segmented_network$moran_results <- arixels
  return(segmented_network)
}