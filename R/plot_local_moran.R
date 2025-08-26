#' @export
plot_local_moran <- function(moran_results_object) {
  
  # 必要なパッケージの確認
  if (!requireNamespace("plotly", quietly = TRUE)) stop("plotly is required.")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr is required.")
  if (!requireNamespace("purrr", quietly = TRUE)) stop("purrr is required.")
  if (!requireNamespace("sf", quietly = TRUE)) stop("sf is required.")
  
  
  segments_sf <- moran_results_object$segments
  moran_df <- moran_results_object$moran_results
  
  to_plot <- moran_df |>
    dplyr::filter(classification != "Insignificant")
  
  # 描画対象がない場合
  if (nrow(to_plot) == 0) {
    warning("No significant clusters found to plot.")
    return(plotly::plot_ly())
  }
  
  # plotlyで描画するためのデータフレームを作成
  plot_df <- purrr::map_dfr(1:nrow(to_plot), function(i) {
    row <- to_plot[i, ]
    seg <- segments_sf[segments_sf$id == row$segment_id, ]
    
    if (nrow(seg) > 0) {
      coords <- sf::st_coordinates(seg)
      rbind(
        data.frame(
          X = coords[, "X"], Y = coords[, "Y"], Time = row$time,
          classification = row$classification,
          Text = paste("Segment:", row$segment_id, "<br>Time:", row$time, "h<br>Class:", row$classification)
        ),
        data.frame(X = NA, Y = NA, Time = NA, classification = row$classification, Text = NA)
      )
    }
  })
  
  

  color_map <- c("HH" = "red", "LL" = "blue", "HL" = "black", "LH" = "lightgrey")
  
  
  # 3Dプロットを作成
  fig <- plotly::plot_ly(
    data = plot_df,
    x = ~X, y = ~Y, z = ~Time,
    color = ~classification,
    colors = color_map,
    type = 'scatter3d',
    mode = 'lines',
    line = list(width = 6),
    hoverinfo = 'text',
    text = ~Text
  ) |>
    plotly::layout(
      title = "Spatio-Temporal Local Moran's I",
      scene = list(
        xaxis = list(title = "X"),
        yaxis = list(title = "Y"),
        zaxis = list(title = "Time (hour)")
      )
    )
  
  return(fig)
}