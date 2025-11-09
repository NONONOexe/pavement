# Create points geometry

This function creates a simple feature collection of points from a
series of x, y coordinates.

## Usage

``` r
create_points(...)

# S3 method for class 'numeric'
create_points(..., crs = NULL, as_multipoint = FALSE)

# S3 method for class 'coordinates'
create_points(coordinates, crs = NULL, as_multipoint = FALSE, ...)
```

## Arguments

- ...:

  A series of x, y coordinates.

- crs:

  The coordinate reference system.

- as_multipoint:

  Logical; if `TRUE`, create a single `MULTIPOINT` geometry instead of
  multiple `POINT` geometries.

- coordinates:

  A `coordinates` object.

## Value

A simple feature geometry list column (`sfc`).

## Examples

``` r
# Create multiple points from individual coordinates
points <- create_points(0, 0, 0, 2, 2, 2, 2, 1, 0, 1)
points
#> Geometry set for 5 features 
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 2 ymax: 2
#> CRS:           NA
#> POINT (0 0)
#> POINT (0 2)
#> POINT (2 2)
#> POINT (2 1)
#> POINT (0 1)
plot(points)


# Create points from a numeric vector
create_points(c(0, 0, 0, 2, 2, 2, 2, 1, 0, 1))
#> Geometry set for 5 features 
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 2 ymax: 2
#> CRS:           NA
#> POINT (0 0)
#> POINT (0 2)
#> POINT (2 2)
#> POINT (2 1)
#> POINT (0 1)

# Create a `MULTIPOINT` instead of separate `POINT`s
create_points(0, 0, 0, 2, 2, 2, 2, 1, 0, 1, as_multipoint = TRUE)
#> Geometry set for 1 feature 
#> Geometry type: MULTIPOINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 2 ymax: 2
#> CRS:           NA
#> MULTIPOINT ((0 0), (0 1), (0 2), (2 1), (2 2))
```
