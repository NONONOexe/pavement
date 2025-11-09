# Create a polygon geometry

This function creates a polygon from a bounding box or a series of x, y
coordinates.

## Usage

``` r
create_polygon(...)

# S3 method for class 'numeric'
create_polygon(..., crs = NULL)

# S3 method for class 'coordinates'
create_polygon(coordinates, crs = NULL, ...)
```

## Arguments

- ...:

  A series of x, y coordinates.

- crs:

  The coordinate reference system.

- coordinates:

  A `coordinates` object.

## Value

A polygon object.

## Examples

``` r
polygon <- create_polygon(
  136.9009, 35.16377,
  136.9159, 35.16377,
  136.9159, 35.17377,
  136.9009, 35.17377,
  crs = 4326
)
```
