#' Plot spatio-temporal local Moran's I results
#'
#' @description
#' Creates a plot to visualize the results of `calculate_local_moran`.
#' The default is a 2D snapshot plot. If `plot_3d` is TRUE, it creates an
#' interactive 3D plot showing significant clusters in a space-time cube.
#'
#' @param moran_results_object The output object from `calculate_local_moran`.
#' @param plot_3d Logical. If `TRUE`, an interactive 3D plot is created.
#'   If `FALSE` (default), a static 2D snapshot plot is created.
#' @param snapshot_time Numeric. The hour (0-23) for which to create the 2D plot.
#'
#' @return A `plotly` object for the 3D plot, or a base R plot for the 2D plot.
#'
#' @export
plot_local_moran <- function(moran_results_object,
                             plot_3d = FALSE,
                             snapshot_time = 12) {

  # Data Preparation
  if (inherits(moran_results_object, "spatiotemporal_network")) {
    segments_sf <- moran_results_object$segment_geometries
  } else {
    segments_sf <- moran_results_object$segments
  }
  moran_df <- moran_results_object$moran_results

  # 3D plot
  if (plot_3d) {
    to_plot <- moran_df[moran_df$classification != "Not Significant", ]

    if (nrow(to_plot) == 0) {
      warning("No significant clusters found to plot.")
      return(plotly::plot_ly())
    }

    # Create dataframe for 3D plotting
    list_of_dfs <- lapply(seq_len(nrow(to_plot)), function(i) {
      row <- to_plot[i, ]
      seg <- segments_sf[segments_sf$id == row$segment_id, ]
      if (nrow(seg) > 0) {
        coords <- sf::st_coordinates(seg)
        rbind(
          data.frame(
            X = coords[, "X"], Y = coords[, "Y"], Time = row$time,
            classification = row$classification,
            GroupID = paste(row$segment_id, row$time)
          ),
          data.frame(X=NA, Y=NA, Time=NA, classification=NA, GroupID=NA)
        )
      }
    })
    plot_df <- do.call(rbind, list_of_dfs)

    color_map <- c("HH" = "red", "LL" = "blue",
                   "HL" = "black", "LH" = "lightgrey")

    fig <- plotly::plot_ly(
      data = plot_df, x = ~X, y = ~Y, z = ~Time,
      split = ~GroupID, color = ~classification, colors = color_map,
      type = 'scatter3d', mode = 'lines', line = list(width = 6)
    ) |>
      plotly::layout(
        title = "Spatio-Temporal Local Moran's I Clusters",
        scene = list(xaxis=list(title="X"), yaxis=list(title="Y"), zaxis=list(title="Time"))
      )
    return(fig)

  } else {
    # 2D snapshot plot

    # Filter for significant clusters at the specified snapshot_time
    to_plot_2d <- moran_df[moran_df$time == snapshot_time &
                             moran_df$classification != "Not Significant", ]

    color_map <- c("HH" = "red", "LL" = "blue",
                   "HL" = "black", "LH" = "lightgrey")

    # Draw the base network
    plot(segments_sf$geometry, main = paste("Local Moran's I Clusters at", snapshot_time, "h"))

    # If significant clusters exist at this time, overlay them with color
    if (nrow(to_plot_2d) > 0) {
      # Get the segment geometries to plot
      segments_to_plot <- segments_sf[segments_sf$id %in% to_plot_2d$segment_id, ]
      # Get the corresponding colors
      plot_colors <- color_map[to_plot_2d$classification]

      # Plot the colored segments
      plot(segments_to_plot$geometry, col = plot_colors, lwd = 3, add = TRUE)
    }

    graphics::legend("topright", legend = names(color_map), fill = color_map,
           title = "Cluster Type", bg = "white")

    return(invisible(NULL))
  }
}
