# Create a bounding box

This function creates a bounding box from either cardinal coordinates
(north, south, east and west) or center coordinates and dimensions
(center longitude and latitude, and size of width and height).

## Usage

``` r
create_bbox(
  north = NULL,
  south = NULL,
  east = NULL,
  west = NULL,
  center_lon = NULL,
  center_lat = NULL,
  width = NULL,
  height = NULL
)
```

## Arguments

- north:

  The northernmost latitude.

- south:

  The southernmost latitude.

- east:

  The easternmost longitude.

- west:

  The westernmost longitude.

- center_lon:

  The center longitude.

- center_lat:

  The center latitude.

- width:

  The width of the bounding box.

- height:

  The height of the bounding box.

## Value

A 2x2 matrix representing the bounding box.

## Examples

``` r
# Create a bounding box from cardinal coordinates
create_bbox(
  north =  35.1899,
  south =  35.1399,
  east  = 136.9524,
  west  = 136.8524
)
#>        min      max
#> x 136.8524 136.9524
#> y  35.1399  35.1899

# Create a bounding box from center coordinates and dimensions
create_bbox(
  center_lon = 136.9024,
  center_lat =  35.1649,
  width      = 0.10,
  height     = 0.05
)
#>        min      max
#> x 136.8524 136.9524
#> y  35.1399  35.1899
```
