# Sample points along a linestring

This function samples points at regular intervals along a linestring
object.

## Usage

``` r
sample_points_along_linestring(linestrings, segment_length)
```

## Arguments

- linestrings:

  A `sfc` object containing linestrings.

- segment_length:

  The desired length of each segment between sampled points.

## Value

A `sfc` object containing the sampled points, grouped as MULTIPOINTs for
each input linestring.

## Examples

``` r
library(sf)

# Create a linestrings
linestrings <- c(
  create_linestring(0, 1, 2, 1),
  create_linestring(1, 1.3, 1, 0, 2, 0.5)
)

# Sample points along the linestrings
sampled_points <- sample_points_along_linestring(linestrings, 0.5)

# Plot the sampled points
plot(linestrings)
plot(sampled_points, add = TRUE, pch = 16, col = c("#E69F00", "#56B4E9"))
```
