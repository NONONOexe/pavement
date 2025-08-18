convolute_spatiotemporal_network <- function(segmented_network,
                                             bandwidth_space = 3,
                                             bandwidth_time  = 2,
                                             time_points = 0:23,
                                             kernel_space = compute_epanechnikov,
                                             kernel_time  = compute_epanechnikov) {

  events <- segmented_network$events
  segments <- segmented_network$segments
  if(is.null(segments) || nrow(segments) == 0) stop("No segments found")
  if(is.null(events) || nrow(events) == 0) stop("No events found")
  if(!"time" %in% names(events)) stop("Events must have a 'time' column")

  n_seg <- nrow(segments)
  seg_index_of_event <- match(events$segment_id, segments$id)
  if(any(is.na(seg_index_of_event))) stop("Some events have segment_id not in segments$id")

  line_graph <- create_line_graph(segmented_network)

  torus_abs_diff <- function(t_eval, t_obs, period = 24) {
    d <- abs(t_eval - t_obs)
    pmin(d, period - d)
  }

  # --- 全時間帯の密度リスト ---
  density_list <- vector("list", length(time_points))
  names(density_list) <- paste0("density_t_", time_points)

  for(t in time_points) {
    dt <- torus_abs_diff(t, events$time)
    w_time <- kernel_time(dt / bandwidth_time) / bandwidth_time

    # Temporal smoothing
    S_t <- numeric(n_seg)
    vals <- rowsum(w_time, seg_index_of_event, reorder = FALSE)
    S_t[as.integer(rownames(vals))] <- as.numeric(vals)

    source_links <- which(S_t > 0)
    if(length(source_links) == 0) {
      density_list[[paste0("density_t_", t)]] <- rep(0, n_seg)
      next
    }

    # Spatial smoothing
    dist_mat <- igraph::distances(line_graph, v = source_links)
    W_space <- kernel_space(dist_mat / bandwidth_space) / bandwidth_space
    W_space[is.na(W_space)] <- 0

    # 正しいブロードキャストで掛け算
    W_weighted <- W_space * matrix(S_t[source_links], nrow = nrow(W_space), ncol = ncol(W_space))

    density_t <- colSums(W_weighted)
    density_list[[paste0("density_t_", t)]] <- density_t
  }

  # --- 全時間帯で正規化 ---
  density_matrix <- do.call(cbind, density_list)
  total_sum <- sum(density_matrix)
  if(total_sum > 0) density_matrix <- density_matrix / total_sum

  # sf に戻す
  for(i in seq_along(density_list)) {
    segments[[names(density_list)[i]]] <- density_matrix[, i]
  }

  segmented_network$segments <- segments
  return(segmented_network)
}
