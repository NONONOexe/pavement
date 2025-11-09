# Extract road intersections

This function identifies and extracts intersections between roads. It
considers only intersections where multiple roads on the same layer.

## Usage

``` r
extract_road_intersections(roads)
```

## Arguments

- roads:

  A linestring object representing roads. It should be have a column
  named `layer` and a column named `road_id`.

## Value

A data frame with the following columns:

- parent_road: A list of road IDs that intersect at the intersection.

- num_overlaps: The number of roads that intersect at the intersection.

## Examples

``` r
# Extract road intersections
intersections <- extract_road_intersections(sample_roads)
intersections
#> Simple feature collection with 3 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 2 ymin: 1 xmax: 6 ymax: 3
#> CRS:           NA
#>    parent_road num_overlaps    geometry
#> 1 rd_0003,....            2 POINT (2 3)
#> 2 rd_0002,....            2 POINT (6 1)
#> 3 rd_0005,....            2 POINT (6 3)

# Plot the intersections
plot(sample_roads$geometry)
plot(intersections$geometry, pch = 16, col = "#E69F00", add = TRUE)
```
