#' Plot Spatio-temporal Local Moran's I results
#'
#' @description
#' Creates an interactive 3D plot to visualize the results of the
#' `calculate_local_moran` function, showing significant spatio-temporal
#' clusters (e.g., High-High, Low-Low) in a space-time cube.
#'
#' @param moran_results_object The output object from `calculate_local_moran`,
#'   which contains a `$moran_results` data frame. The function can handle
#'   objects of class `segmented_network` or `spatiotemporal_network`.
#'
#' @return A `plotly` object representing the interactive 3D plot.
#'
#' @export
plot_local_moran <- function(moran_results_object) {


  # --- Data Preparation ---
  # Detect object class and extract geometries from the correct location
  if (inherits(moran_results_object, "spatiotemporal_network")) {
    segments_sf <- moran_results_object$segment_geometries
  } else {
    segments_sf <- moran_results_object$segments
  }

  moran_df <- moran_results_object$moran_results

  to_plot <- moran_df |>
    dplyr::filter(classification != "Not Significant")

  # Return an empty plot if there's nothing to show
  if (nrow(to_plot) == 0) {
    warning("No significant clusters found to plot.")
    return(plotly::plot_ly())
  }

  # --- Create DataFrame for Plotting ---
  # This loop transforms the sf data into a format suitable for plotly's 3D lines
  plot_df <- purrr::map_dfr(1:nrow(to_plot), function(i) {
    row <- to_plot[i, ]
    seg <- segments_sf[segments_sf$id == row$segment_id, ]

    if (nrow(seg) > 0) {
      coords <- sf::st_coordinates(seg)
      # Add an NA row to break the line between different segments in plotly
      rbind(
        data.frame(
          X = coords[, "X"], Y = coords[, "Y"], Time = row$time,
          classification = row$classification,
          GroupID = paste(row$segment_id, row$time), # ID for grouping lines
          Text = paste("Segment:", row$segment_id, "<br>Time:", row$time, "h<br>Class:", row$classification)
        ),
        data.frame(X = NA, Y = NA, Time = NA, classification = NA, GroupID = NA, Text = NA)
      )
    }
  })

  # --- Create 3D Plot ---
  # Define a color map for the cluster types
  color_map <- c("HH" = "red",
                 "LL" = "blue",
                 "HL" = "black",
                 "LH" = "lightgray")

  # Create the 3D plot using plotly
  fig <- plotly::plot_ly(
    data = plot_df,
    x = ~X, y = ~Y, z = ~Time,
    split = ~GroupID, # Use GroupID to draw separate lines for each segment
    color = ~classification,
    colors = color_map,
    type = 'scatter3d',
    mode = 'lines',
    line = list(width = 6),
    hoverinfo = 'text',
    text = ~Text
  ) |>
    plotly::layout(
      title = "Spatio-Temporal Local Moran's I Clusters",
      scene = list(
        xaxis = list(title = "X"),
        yaxis = list(title = "Y"),
        zaxis = list(title = "Time (hour)")
      )
    )

  return(fig)
}
