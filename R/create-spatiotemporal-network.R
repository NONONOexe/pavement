#' Create spatiotemporal network
#'
#' This function creates a spatiotemporal network from a road network.
#'
#' @param road_network A `road_network` object.
#' @param spatial_length The spatial length of segment.
#' @param temporal_length The temporal length of segment.
#' @param events A event collection object.
#' @param ... Additional arguments passed to or from other methods.
#' @return A `spatiotemporal_network` object.
#' @name spatiotemporal_network
#' @aliases create_spatiotemporal_network
#' @export
#' @examples
#' # Create a road network
#' road_network <- create_road_network(sample_roads)
#'
#' # Create a spatiotemporal road network
#' spatiotemporal_network <- create_spatiotemporal_network(
#'   road_network,
#'   spatial_length = 0.5,
#'   temporal_length = "4 hour"
#' )
#' spatiotemporal_network
#'
#' # Plot the spatiotemporal road network
#' plot(spatiotemporal_network)
create_spatiotemporal_network <- function(road_network,
                                          spatial_length = 1,
                                          temporal_length = "1 hour",
                                          events = NULL,
                                          ...) {
  UseMethod("create_spatiotemporal_network")
}

#' @export
create_spatiotemporal_network.road_network <- function(road_network,
                                                       spatial_length = 1,
                                                       temporal_length = "1 hour",
                                                       events = NULL,
                                                       ...) {
  # Extract network nodes and links
  network_nodes <- extract_segmented_network_nodes(road_network, spatial_length)
  network_links <- extract_segmented_network_links(road_network, network_nodes)
  spatial_graph <- create_graph(network_nodes, network_links,
                                directed = igraph::is_directed(road_network$graph))

  # Create time intervals
  network_durations <- create_durations(temporal_length)

  # Calculate the total number of spatiotemporal segments
  num_segments <- nrow(network_links)
  num_intervals <- nrow(network_durations)
  total_segments <- num_segments * num_intervals

  # Replicate segments for each time interval
  spatiotemporal_segments <- data.frame(
    id       = sprintf("ts_%010x", seq_len(total_segments)),
    geometry = rep(network_links$id, num_intervals),
    duration = rep(network_durations$id, each = num_segments),
    count    = 0,
    density  = 0
  )

  # Create the spatiotemporal network object
  spatiotemporal_network <- list(
    segments           = spatiotemporal_segments,
    segment_geometries = network_links,
    segment_durations  = network_durations,
    spatial_graph      = spatial_graph,
    origin_network     = road_network,
    spatial_length     = spatial_length,
    temporal_length    = temporal_length
  )
  class(spatiotemporal_network) <- "spatiotemporal_network"

  # Assign events if available
  if (!is.null(events) || !is.null(road_network$events)) {
    if (!is.null(events) && !is.null(road_network$events)) {
      warning("events already exist in the road network")
    }
    spatiotemporal_network <- set_events(spatiotemporal_network,
                                         events %||% road_network$events)
  }

  return(spatiotemporal_network)
}


#' Plot spatiotemporal network or TNKDE results
#'
#' @description
#' Creates a plot to visualize the events, counts, or **TNKDE density** on a
#' spatiotemporal network. The default is a 2D snapshot plot. The 3D view is
#' optimized for visualizing TNKDE results across time.
#'
#' @param x The `spatiotemporal_network` object (often the output of `convolute_spatiotemporal_network`).
#' @param y (Not used).
#' @param mode Character string specifying the type of visualization:
#'   `"event"` (individual points), `"count"` (event count per segment), or `"density"` (TNKDE density).
#' @param snapshot_time Numeric. The hour (0-23) for which to create the static 2D snapshot plot.
#' @param plot_3d Logical. If `TRUE`, an interactive 3D plot using `rgl` is created.
#' @param time_range Numeric vector (e.g., 0:23) specifying the time points to include in the 3D plot.
#' @param ... Additional arguments passed to helper functions.
#'
#' @return `NULL` (invisibly). Opens an interactive `rgl` window for 3D plots, or draws a base R plot for 2D.
#'
#' @export
#'
#' @examples
#' # Run the TNKDE calculation
#' tnkde_result <- sample_roads |>
#'   create_road_network() |>
#'   create_spatiotemporal_network(
#'     spatial_length = 0.5,
#'     temporal_length = "1 hour"
#'   ) |>
#'   set_events(sample_accidents, time_column = "time") |>
#'   convolute_spatiotemporal_network(
#'     bandwidth_space = 2,
#'     bandwidth_time = 1.5,
#'     time_points = 0:23
#'   )
#'
#' # Plotting examples:
#'
#' # A. 2D Snapshot: smoothed density
#' # Use Case: Visualize the primary analysis result at 19:00.
#' plot(tnkde_result, mode = "density", snapshot_time = 19)
#'
#' # B. 2D Snapshot: raw event counts per segment
#' # Use Case: See raw event counts at a specific hour (e.g., 7:00).
#' plot(tnkde_result, mode = "count", snapshot_time = 7)
#'
#' # C. 3D Plot: full density cube
#' # This is the primary visualization for spatiotemporal analysis.
#' # plot(tnkde_result, mode = "density", plot_3d = TRUE)
plot.spatiotemporal_network <- function(x,
                                        y,
                                        mode = c("event", "count", "density"),
                                        snapshot_time = 12,
                                        plot_3d = FALSE,
                                        time_range = 0:23,
                                        ...) {
  mode <- match.arg(mode)

  segments_sf <- x$segment_geometries
  events_sf <- x$events


  get_heatmap_colours <- function(values, global_max = NULL) {
    heatmap_colours <- paste0(heat.colors(100, rev = TRUE), "CD")

    if (length(values) == 0 || all(is.na(values))) {
      return(rep(heatmap_colours[1], length(values)))
    }

    if (is.null(global_max)) {
      global_max <- max(values, na.rm = TRUE)
    }

    if (global_max == 0) {
      return(rep(heatmap_colours[1], length(values)))
    }

    normalized <- values / global_max
    normalized <- pmin(pmax(normalized, 0), 1)
    idx <- ceiling(normalized * 99) + 1
    cols <- heatmap_colours[idx]

    return(cols)
  }

  plot_legends <- function(values, main_label, global_max) {
    digits <- ifelse(main_label == "Count", 0, 5)
    labels <- unique(round(seq(0, global_max, length.out = 5), digits))

    par(fig = c(0.75, 0.95, 0.2, 0.8),
        mar = c(0, 0, 2.5, 0.5),
        cex.main = 0.8,
        cex.axis = 0.7,
        new = TRUE)

    norm_vals <- seq(0, global_max, length.out = 100)
    plot(x = rep(1, 100),
         y = seq(0, 1, length.out = 100),
         xlim = c(0, 1),
         col = get_heatmap_colours(norm_vals, global_max = global_max),
         type = "n",
         xaxs = "i",
         yaxs = "i",
         axes = FALSE,
         main = main_label)

    segments(x0 = 0.45, x1 = 0.55,
             y0 = seq(0, 1, length.out = 100),
             y1 = seq(0, 1, length.out = 100),
             col = get_heatmap_colours(norm_vals, global_max = global_max),
             lwd = 20, lend = "butt")

    axis(4, at = seq(0, 1, length.out = length(labels)),
         labels = labels, line = -2.0, tick = TRUE, las = 2)
  }

  plot_coloured_segmented_network <- function(segments,
                                              segment_values,
                                              mode,
                                              global_max,
                                              ...) {

    par(fig = c(0, 0.8, 0, 1), mar = c(5, 4, 4, 2))
    plot(segments, lwd = 1, ...)

    if (max(segment_values, na.rm = TRUE) == 0) {
      warning("all segment values are zero")
    } else {
      plot(segments,
           col = get_heatmap_colours(segment_values, global_max = global_max),
           lwd = ifelse(segment_values == 0, 1, 2),
           add = TRUE,
           ...)
    }

    plot_legends(segment_values, mode, global_max = global_max, ...)
    reset_layout()
  }

  plot_segments_and_points <- function(segments, points, col, pch, lwd_seg=1, ...) {
    plot(segments, lwd = lwd_seg, ...)
    if (!is.null(points) && length(points) > 0) {
      plot(points, cex = 1, col = col, pch = pch, add = TRUE, ...)
    }
  }

  reset_layout <- function() {
    par(fig = c(0,1,0,1), mar = c(5,4,4,2)+0.1, oma = c(0,0,0,0))
  }



  # 2D plot
  if (!plot_3d) {
    if (mode == "event") {
      snapshot_events <- events_sf[events_sf$time == snapshot_time, ]
      points_to_plot <- NULL
      if (!is.null(snapshot_events) && nrow(snapshot_events) > 0) {
        points_to_plot <- sf::st_geometry(snapshot_events)
      }
      plot_segments_and_points(segments_sf$geometry,
                               points_to_plot,
                               col="red", pch=4)

    } else if (mode == "count") {
      snapshot_events <- events_sf[events_sf$time == snapshot_time, ]
      counts <- rep(0, nrow(segments_sf))
      if (!is.null(snapshot_events) && nrow(snapshot_events) > 0) {
        for (i in seq_len(nrow(segments_sf))) {
          seg_id <- segments_sf$id[i]
          counts[i] <- sum(snapshot_events$segment_id == seg_id)
        }
      }
      plot_coloured_segmented_network(segments_sf$geometry,
                                      counts,
                                      "Count",
                                      global_max = max(counts))

    } else if (mode == "density") {
      all_density_cols <- names(x$segments)[startsWith(names(x$segments), "density_t_")]
      all_densities <- as.numeric(unlist(sf::st_drop_geometry(x$segments[, all_density_cols])))
      global_max_density <- max(all_densities, na.rm = TRUE)

      density_col <- paste0("density_t_", snapshot_time)
      density_values <- as.numeric(sf::st_drop_geometry(x$segments[[density_col]]))

      segments_geom <- sf::st_geometry(x$segments)

      plot_coloured_segmented_network(segments_geom,
                                      density_values,
                                      "Density",
                                      global_max = global_max_density)
    }
    return(invisible(NULL))
  }

  # 3D plot
  if (plot_3d) {

    rgl::open3d()
    rgl::bg3d("white")
    rgl::material3d(col="black")

    for (i in seq_len(nrow(segments_sf))) {
      seg_geom <- sf::st_cast(sf::st_geometry(segments_sf[i,]), "LINESTRING")
      coords <- sf::st_coordinates(seg_geom)

      rgl::lines3d(coords[,1], coords[,2], rep(0, nrow(coords)),
                   color = "lightgrey", lwd = 2)

      if (mode == "event") {
        seg_events <- events_sf[events_sf$segment_id == segments_sf$id[i] &
                                  events_sf$time %in% time_range, ]
        if (nrow(seg_events) > 0) {
          coords_ev <- sf::st_coordinates(seg_events)
          z <- seg_events$time
          rgl::text3d(coords_ev[,1], coords_ev[,2], z,
                      texts = "x",
                      color = "red",
                      cex = 1.0)
        }

      } else if (mode == "count") {
        counts_all <- table(events_sf$segment_id)
        max_count <- max(counts_all, na.rm = TRUE)

        for (t in time_range) {
          seg_events <- events_sf[events_sf$time == t, ]
          for (i in seq_len(nrow(segments_sf))) {
            seg_id <- segments_sf$id[i]
            count_val <- sum(seg_events$segment_id == seg_id)
            if (count_val > 0) {
              seg_geom <- sf::st_cast(sf::st_geometry(segments_sf[i, ]), "LINESTRING")
              coords <- sf::st_coordinates(seg_geom)
              col <- get_heatmap_colours(count_val)
              rgl::lines3d(coords[,1], coords[,2], rep(t, nrow(coords)),
                           color = col, lwd = 3)
            }
          }
        }

        legend_labels <- 0:max_count
        legend_colors <- get_heatmap_colours(legend_labels)
        rgl::legend3d("topright", legend = legend_labels,
                      fill = legend_colors, title = "Count")

      } else if (mode == "density") {
        density_cols <- names(x$segments)[startsWith(names(x$segments), "density_t_")]
        time_cols_to_plot <- paste0("density_t_", time_range)
        density_cols_exist <- intersect(density_cols, time_cols_to_plot)
        if (length(density_cols_exist) == 0) {
          warning("No density columns found for the specified time_range.")
          return(invisible(NULL))
        }

        density_matrix <- as.matrix(sf::st_drop_geometry(x$segments[, density_cols_exist]))
        density_matrix[is.na(density_matrix)] <- 0

        all_densities <- as.vector(density_matrix)
        max_density <- max(all_densities)

        all_colors <- get_heatmap_colours(all_densities, global_max = max_density)

        color_matrix <- matrix(all_colors, nrow = nrow(density_matrix), ncol = ncol(density_matrix))

        for (t_idx in seq_along(time_range)) {
          t <- time_range[t_idx]
          density_val <- density_matrix[i, t_idx]
          if (density_val > 0) {
            col <- color_matrix[i, t_idx]
            rgl::lines3d(coords[,1], coords[,2], rep(t, nrow(coords)),
                         color = col, lwd = 3)
          }
        }

        legend_labels <- round(seq(0, max_density, length.out = 5), 3)
        legend_colors <- get_heatmap_colours(legend_labels, global_max = max_density)
        rgl::legend3d("topright", legend = as.character(legend_labels),
                      fill = legend_colors, title = "Density")
      }
    }

    rgl::axes3d()
    rgl::title3d("X","Y","Time",main=paste("TNKDE 3D:", mode))
    return(invisible(NULL))
  }
}
