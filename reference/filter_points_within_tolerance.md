# Filter points within a tolerance distance

This function filters points that are within a specified tolerance
distance from a reference linestring.

## Usage

``` r
filter_points_within_tolerance(points, linestring, tolerance = 0.01)
```

## Arguments

- points:

  A `sfc` object containing points to filter.

- linestring:

  A linestring object.

- tolerance:

  A numeric value representing the maximum allowable distance between
  points and the linestring. Points within this distance from the
  linestring will be included in the filtered set.

## Value

A `sfc` object containing the filtered points.

## Examples

``` r
# Create a points
points <- create_points(
  0.000, 1.000, 0.500, 0.600, 1.000, 0.010, 1.500, 0.501, 2.000, 0.990
)

# Create a linestring
linestring <- create_linestring(0, 1, 1, 0, 2, 1)

# Plot the points
plot(linestring, col = "gray")
plot(points, add = TRUE)


# Filter points within a tolerance distance (default: 0.01)
filtered_points <- filter_points_within_tolerance(points, linestring)

# Plot the filtered points
plot(linestring, col = "gray")
plot(filtered_points, add = TRUE)
```
