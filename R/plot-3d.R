#' Plot TNKDE results in a 3D space-time cube
#'
#' @description
#' A unified plotting function for visualizing spatio-temporal kernel density
#' estimation (TNKDE) results in different modes:
#' - `"event"`: plots event points in 3D (X, Y, time) with the road network as background.
#' - `"count"`: plots segment-level event counts with a color scale over time.
#' - `"density"`: plots density values along segments using rgl (opens a separate 3D window).
#'
#' @param tnkde_result A `segmented_network` object containing the TNKDE results.
#' @param mode Character string, one of `"event"`, `"count"`, or `"density"`.
#' @param time_range Numeric vector specifying which time points to plot (default: `0:23`).
#' @param ... Additional arguments passed to [plotly::plot_ly()] (only used for `"event"` and `"count"` modes).
#'
#' @details
#' - `"event"` and `"count"` modes use **plotly** and return an interactive plot
#'   in the RStudio Viewer or browser.
#' - `"density"` mode uses **rgl** and opens a separate OpenGL window for interactive 3D visualization.
#'   In this mode, nothing is returned (invisible `NULL`).
#'
#' @return
#' - For `"event"` and `"count"`: a [plotly::plotly] object.
#' - For `"density"`: `NULL` (a 3D rgl window is opened instead).
#'
#' @examples
#' \dontrun{
#' tnkde_network <- sample_roads |>
#'   create_road_network() |>
#'   create_segmented_network(segment_length = 0.5) |>
#'   prepare_tnkde_data(sample_accidents) |>
#'   convolute_spatiotemporal_network(
#'     bandwidth_space = 3,
#'     bandwidth_time = 2,
#'     time_points = 0:23
#'   )
#'
#' # Plot event mode
#' plot_tnkde_3d(tnkde_network, mode = "event")
#'
#' # Plot count mode
#' plot_tnkde_3d(tnkde_network, mode = "count")
#'
#' # Plot density mode (rgl window)
#' plot_tnkde_3d(tnkde_network, mode = "density")
#' }
#'
#' @export
plot_tnkde_3d <- function(tnkde_result,
                          mode = c("event", "count", "density"),
                          time_range = 0:23,
                          ...) {
  mode <- match.arg(mode)

  if (!requireNamespace("plotly", quietly = TRUE)) stop("plotly is required.")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr is required.")

  segments_sf <- tnkde_result$segments
  events_sf   <- tnkde_result$events

  prepare_lines <- function(sf_line) {
    as.data.frame(sf::st_coordinates(sf_line)[, c("X", "Y")])
  }

  fig <- plotly::plot_ly(...)

  # --- event mode ---
  if(mode == "event") {
    if(is.null(events_sf) || nrow(events_sf) == 0) stop("No events found")

    event_coords <- sf::st_coordinates(events_sf)
    event_time <- events_sf$time

    # 事故地点をプロット
    fig <- plotly::add_trace(fig,
                             x = ~event_coords[,"X"], y = ~event_coords[,"Y"], z = ~event_time,
                             type="scatter3d", mode="markers",
                             marker = list(size=2, color='red', symbol='x'),
                             name="Events", inherit = FALSE
    )

    # 背景として全時間帯の道路網をプロット
    segment_coords <- do.call(rbind, lapply(1:nrow(segments_sf), function(i){
      coords_seg <- prepare_lines(segments_sf[i,])
      rbind(coords_seg, data.frame(X=NA, Y=NA))
    }))

    for(t in time_range){
      fig <- plotly::add_trace(fig,
                               x=~segment_coords$X, y=~segment_coords$Y, z=t,
                               type="scatter3d", mode="lines",
                               line=list(color='grey', width=2),
                               showlegend=FALSE, inherit=FALSE,
                               hoverinfo = 'none'
      )
    }
    return(fig)
  }

  # --- count mode ---
  if(mode == "count") {
    if(is.null(events_sf) || nrow(events_sf) == 0) stop("No events found")
    hourly_counts <- events_sf |>
      sf::st_drop_geometry() |>
      dplyr::group_by(segment_id, time) |>
      dplyr::summarise(count=dplyr::n(), .groups="drop")

    # 背景全セグメント
    all_grey_df <- do.call(rbind, lapply(time_range, function(t){
      coords <- do.call(rbind, lapply(1:nrow(segments_sf), function(i){
        rbind(prepare_lines(segments_sf[i,]), data.frame(X=NA,Y=NA))
      }))
      data.frame(X=coords$X, Y=coords$Y, Time=t, GroupID=t)
    }))
    fig <- plotly::add_trace(fig, data=all_grey_df,
                             x=~X, y=~Y, z=~Time, split=~GroupID,
                             type="scatter3d", mode="lines",
                             line=list(color='grey', width=1),
                             showlegend=FALSE, hoverinfo="none")

    # 色付きセグメント
    if(nrow(hourly_counts) > 0){
      colored_df <- do.call(rbind, lapply(1:nrow(hourly_counts), function(i){
        row <- hourly_counts[i,]
        seg <- segments_sf[segments_sf$id==row$segment_id,]
        if(nrow(seg) > 0){
          coords <- rbind(prepare_lines(seg), data.frame(X=NA,Y=NA))
          data.frame(X=coords$X, Y=coords$Y, Time=row$time,
                     Count=row$count,
                     GroupID=paste(row$segment_id,row$time))
        }
      }))

      max_count <- max(colored_df$Count, na.rm = TRUE)
      tick_values <- 0:ceiling(max_count)

      # カスタムカラースケール：薄い黄色 -> オレンジ -> 鮮やかな赤
      custom_colorscale <- list(c(0, "#FFFFE0"), c(0.5, "#FFA500"), c(1, "#FF0000"))

      fig <- plotly::add_trace(fig, data=colored_df,
                               x=~X, y=~Y, z=~Time, split=~GroupID,
                               type="scatter3d", mode="lines",
                               line=list(
                                 color=~Count,
                                 colorscale = custom_colorscale, # カスタムカラースケールを使用
                                 reversescale = FALSE, # 反転は不要
                                 cmin = 0,
                                 cmax = max_count,
                                 colorbar=list(
                                   title="Count",
                                   tickmode = "array",
                                   tickvals = tick_values,
                                   ticktext = as.character(tick_values)
                                 ),
                                 width=5
                               ),
                               showlegend=FALSE)
    }
    return(fig)
  }

  if(mode == "density") {
    if (!requireNamespace("rgl", quietly = TRUE)) stop("rgl is required.")
    if (!requireNamespace("sf", quietly = TRUE)) stop("sf is required.")
    if (!requireNamespace("viridis", quietly = TRUE)) stop("viridis is required.")

    segments_sf <- tnkde_result$segments
    time_points <- time_range

    # --- rgl 初期化 ---
    rgl::open3d()
    rgl::bg3d("white")
    rgl::material3d(col = "black")

    # density 行列作成
    density_matrix <- do.call(cbind, lapply(time_points, function(t) {
      colname <- paste0("density_t_", t)
      if(colname %in% names(segments_sf)) {
        segments_sf[[colname]]
      } else {
        rep(0, nrow(segments_sf))
      }
    }))
    density_matrix[is.na(density_matrix)] <- 0

    # min / max を記録
    min_density <- min(density_matrix)
    max_density <- max(density_matrix)

    for (i in seq_len(nrow(segments_sf))) {
      seg_geom <- st_cast(st_geometry(segments_sf[i, ]), "LINESTRING")
      coords <- st_coordinates(seg_geom)

      for (t_idx in seq_along(time_points)) {
        z <- rep(time_points[t_idx], nrow(coords))
        density_val <- density_matrix[i, t_idx]

        # 正規化
        val_norm <- (density_val - min_density) / (max_density - min_density)
        val_norm <- max(0, min(1, val_norm))  # 安全策

        col <- viridis::viridis(100)[ceiling(val_norm * 99) + 1]

        lines3d(coords[,1], coords[,2], z, color = col, lwd = 3)
      }
    }

    # 凡例を元の密度値で表示
    legend_labels <- round(seq(min_density, max_density, length.out = 5), 3)
    legend_colors <- viridis::viridis(5)
    rgl::legend3d("topright", legend = legend_labels,
                  fill = legend_colors, title = "Density")

    axes3d()
    title3d("X", "Y", "Time", main = "TNKDE 3D Visualization")

    return(invisible(NULL))
  }
}
