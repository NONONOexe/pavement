#' Plot TNKDE results in a 3D space-time cube
#'
#' @description
#' A unified plotting function for visualizing spatio-temporal kernel density
#' estimation (TNKDE) results.
#'
#' @param tnkde_result A `segmented_network` or `spatiotemporal_network` object
#'   containing the TNKDE results.
#' @param mode Character string, one of `"event"`, `"count"`, or `"density"`.
#' @param time_range Numeric vector specifying which time points to plot (default: `0:23`).
#' @param ... Additional arguments passed to [plotly::plot_ly()].
#'
#' @details
#' - `"event"` and `"count"` modes use **plotly**.
#' - `"density"` mode uses **rgl** and opens a separate OpenGL window.
#'
#' @return A [plotly::plotly] object for "event" and "count" modes, or `NULL`
#'   for "density" mode (which opens an rgl window).
#'
#' @examples
#' \dontrun{
#' # (Example code remains the same)
#' }
#'
#' @export
plot_tnkde <- function(tnkde_result,
                          mode = c("event", "count", "density"),
                          time_range = 0:23,
                          ...) {
  mode <- match.arg(mode)


  segments_sf <- tnkde_result$segments
  events_sf   <- tnkde_result$events


  # --- Helper function to prepare line coordinates for plotting ---
  prepare_lines <- function(sf_line) {
    as.data.frame(sf::st_coordinates(sf_line)[, c("X", "Y")])
  }


  # --- Event Mode ---
  if(mode == "event") {
    if(is.null(events_sf) || nrow(events_sf) == 0) stop("No events found for plotting.")

    fig <- plotly::plot_ly(...)
    event_coords <- sf::st_coordinates(events_sf)
    event_time <- events_sf$time

    # Plot event locations as markers
    fig <- plotly::add_trace(fig,
                             x = ~event_coords[,"X"], y = ~event_coords[,"Y"], z = ~event_time,
                             type="scatter3d", mode="markers",
                             marker = list(size=2, color='red', symbol='x'),
                             name="Events", inherit = FALSE)

    # Plot the road network as a grey background at each time slice
    segment_coords <- do.call(rbind, lapply(1:nrow(segments_sf), function(i){
      coords_seg <- prepare_lines(segments_sf[i,])
      rbind(coords_seg, data.frame(X=NA, Y=NA)) # NA row to break lines
    }))

    for(t in time_range){
      fig <- plotly::add_trace(fig,
                               x=~segment_coords$X, y=~segment_coords$Y, z=t,
                               type="scatter3d", mode="lines",
                               line=list(color='grey', width=2),
                               showlegend=FALSE, inherit=FALSE,
                               hoverinfo = 'none')
    }
    return(fig)
  }

  # --- Count Mode ---
  if(mode == "count") {
    if(is.null(events_sf) || nrow(events_sf) == 0) stop("No events found for plotting.")

    fig <- plotly::plot_ly(...)

    hourly_counts <- events_sf |>
      sf::st_drop_geometry() |>
      dplyr::group_by(segment_id, time) |>
      dplyr::summarise(count=dplyr::n(), .groups="drop")


    # Plot all segments as a grey background

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

    # Overlay colored segments based on event counts
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
      # Custom colorscale: light yellow -> orange -> bright red
      custom_colorscale <- list(c(0, "#FFFFE0"), c(0.5, "#FFA500"), c(1, "#FF0000"))

      fig <- plotly::add_trace(fig, data=colored_df,
                               x=~X, y=~Y, z=~Time, split=~GroupID,
                               type="scatter3d", mode="lines",
                               line=list(
                                 color=~Count,
                                 colorscale = custom_colorscale,
                                 reversescale = FALSE,
                                 cmin = 0, cmax = max_count,
                                 colorbar=list(title="Count", tickmode="array", tickvals=tick_values),
                                 width=5
                               ),
                               showlegend=FALSE)
    }
    return(fig)
  }

  # --- Density Mode ---
  if(mode == "density") {
    # Prepare data for rgl plotting
    density_cols <- names(segments_sf)[startsWith(names(segments_sf), "density_t_")]
    time_cols_to_plot <- paste0("density_t_", time_range)
    density_cols_exist <- intersect(density_cols, time_cols_to_plot)
    if(length(density_cols_exist) == 0){
      warning("No density columns found for the specified time_range.")
      return(invisible(NULL))
    }
    density_matrix <- as.matrix(sf::st_drop_geometry(segments_sf[, density_cols_exist]))
    density_matrix[is.na(density_matrix)] <- 0

    # Record min/max for color scaling
    min_density <- min(density_matrix)
    max_density <- max(density_matrix)

    # Initialize rgl window
    rgl::open3d()
    rgl::bg3d("white")
    rgl::material3d(col = "black")

    # Plot each segment for each time point
    for (i in seq_len(nrow(segments_sf))) {
      seg_geom <- sf::st_cast(sf::st_geometry(segments_sf[i, ]), "LINESTRING")
      coords <- sf::st_coordinates(seg_geom)

      for (t_idx in seq_along(time_range)) {
        z <- rep(time_range[t_idx], nrow(coords))
        density_val <- density_matrix[i, t_idx]

        # Normalize density to map to a color
        val_norm <- if (max_density > min_density) {
          (density_val - min_density) / (max_density - min_density)
        } else { 0 }

        col <- viridis::viridis(100)[ceiling(val_norm * 99) + 1]
        rgl::lines3d(coords[,1], coords[,2], z, color = col, lwd = 3)
      }
    }

    # Add legend and axes, using the original density values
    legend_labels <- round(seq(min_density, max_density, length.out = 5), 3)
    legend_colors <- viridis::viridis(5)
    rgl::legend3d("topright", legend = as.character(legend_labels),
                  fill = legend_colors, title = "Density")
    rgl::axes3d()
    rgl::title3d("X", "Y", "Time", main = "TNKDE 3D Visualization")

    return(invisible(NULL))
  }
}
