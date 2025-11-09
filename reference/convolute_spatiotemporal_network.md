# Convolute a spatiotemporal network to perform TNKDE

This function performs Temporal Network Kernel Density Estimation
(TNKDE) on a spatiotemporal network object. It calculates density values
across the network's segments for a series of time points.

## Usage

``` r
convolute_spatiotemporal_network(
  segmented_network,
  kernel_space = compute_epanechnikov,
  kernel_time = compute_epanechnikov,
  bandwidth_space = 3,
  bandwidth_time = 2,
  time_points = 0:23,
  use_esd = TRUE,
  correct_boundary_effects = TRUE
)
```

## Arguments

- segmented_network:

  A spatiotemporal network object, typically the output of
  [`create_spatiotemporal_network()`](https://nononoexe.github.io/pavement/reference/spatiotemporal_network.md)
  followed by
  [`set_events()`](https://nononoexe.github.io/pavement/reference/set_events.md).

- kernel_space:

  The spatial kernel function (default: `compute_epanechnikov`).

- kernel_time:

  The temporal kernel function (default: `compute_epanechnikov`).

- bandwidth_space:

  The spatial bandwidth (in the network's distance units).

- bandwidth_time:

  The temporal bandwidth (in hours).

- time_points:

  A numeric vector of time points (e.g., hours 0:23) at which to
  estimate the density.

- use_esd:

  If `TRUE` (default), uses the Equal Split Discontinuous (ESD) kernel
  for spatial smoothing to account for network intersections.

- correct_boundary_effects:

  If `TRUE` (default), corrects for boundary effects by normalizing the
  kernel weights from each source to sum to 1.

## Value

The input network object with the `$segments` component updated to an
`sf` data frame of spatial segments, now containing new columns
(`density_t_0`, `density_t_1`, etc.) with the calculated density values.
The total density over all segments and time points is normalized to sum
to 1.

## Examples

``` r
if (FALSE) { # \dontrun{
# Create a network and assign events
tnkde_input <- sample_roads |>
  create_road_network() |>
  create_spatiotemporal_network(
    spatial_length = 0.5,
    temporal_length = "1 hour"
  ) |>
  set_events(sample_accidents, time_column = "time")

# Run the TNKDE calculation
tnkde_result <- convolute_spatiotemporal_network(
  tnkde_input,
  bandwidth_space = 2,
  bandwidth_time = 1.5,
  time_points = 0:23
)

# View the results
print(tnkde_result$segments)

# Plot the results
# Plot a 2D snapshot for a specific time
plot(tnkde_result, mode = "density", snapshot_time = 19)

# Plot the full 3D space-time cube
plot(tnkde_result, mode = "density", plot_3d = TRUE)
} # }
```
