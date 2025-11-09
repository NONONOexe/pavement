# Create a linestring geometry

This function creates a simple feature linestring object from a series
of x, y coordinates.

## Usage

``` r
create_linestring(...)

# S3 method for class 'numeric'
create_linestring(..., crs = NULL)

# S3 method for class 'coordinates'
create_linestring(coordinates, crs = NULL, ...)
```

## Arguments

- ...:

  A series of x, y coordinates.

- crs:

  The coordinate reference system.

- coordinates:

  A `coordinates` object.

## Value

A simple feature linestring object.

## Examples

``` r
# Create a linestring from individual coordinates
linestring_1 <- create_linestring(0, 1, 1, 0, 2, 1)
linestring_1
#> Geometry set for 1 feature 
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 2 ymax: 1
#> CRS:           NA
#> LINESTRING (0 1, 1 0, 2 1)
plot(linestring_1)


# Create a linestring from a numeric vector
linestring_2 <- create_linestring(
  c(0, 1, 1, 1, 1, 0, 0, 0, 0, 0.5, 1, 0.5)
)
linestring_2
#> Geometry set for 1 feature 
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 1 ymax: 1
#> CRS:           NA
#> LINESTRING (0 1, 1 1, 1 0, 0 0, 0 0.5, 1 0.5)
plot(linestring_2)
```
