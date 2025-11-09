# Plot spatio-temporal local Moran's I results

Creates a plot to visualize the results of `calculate_local_moran`. The
default is a 2D snapshot plot. If `plot_3d` is TRUE, it creates an
interactive 3D plot showing significant clusters in a space-time cube.

## Usage

``` r
plot_local_moran(moran_results_object, plot_3d = FALSE, snapshot_time = 12)
```

## Arguments

- moran_results_object:

  The output object from `calculate_local_moran`.

- plot_3d:

  Logical. If `TRUE`, an interactive 3D plot is created. If `FALSE`
  (default), a static 2D snapshot plot is created.

- snapshot_time:

  Numeric. The hour (0-23) for which to create the 2D plot.

## Value

A `plotly` object for the 3D plot, or `NULL` for the 2D plot.

## Examples

``` r
if (FALSE) { # \dontrun{
# First, run the Local Moran's I calculation
moran_result <- sample_roads |>
  create_road_network() |>
  create_spatiotemporal_network(spatial_length = 0.5) |>
  set_events(sample_accidents) |>
  calculate_local_moran(dist_threshold = 1, time_threshold = 2)

# --- Plotting Examples ---

# 1. Plot a 2D snapshot for a specific time (e.g., 19:00)
plot_local_moran(moran_result, snapshot_time = 19)

# 2. Plot the full 3D space-time cube
plot_local_moran(moran_result, plot_3d = TRUE)
} # }
```
