# Convert a bounding box to coordinates or a polygon

This function converts a bounding box to either coordinates or a
polygon.

## Usage

``` r
convert_bbox(bbox, output = c("coordinates", "polygon"), crs = NULL)

convert_bbox_to_coordinates(bbox)

convert_bbox_to_polygon(bbox, crs = NULL)
```

## Arguments

- bbox:

  A numeric matrix with two columns and two rows. `bbox` represents the
  minimum and maximum coordinates. The bounding box can be created using
  the `create_bbox` function.

- output:

  A string specifying the output type. Either "coordinates" or
  "polygon".

- crs:

  A string specifying the coordinate reference system. This is only used
  when converting to a polygon.

## Value

A `coordinates` object or a `sfc` polygon object.

## Examples

``` r
bbox <- create_bbox(center_lon = 136.9024,
                    center_lat =  35.1649,
                    width      = 0.10,
                    height     = 0.05)
convert_bbox_to_coordinates(bbox)
#> {(136.8524, 35.1399), (136.9524, 35.1399), (136.9524, 35.1899), (136.8524, 35.1899)}
convert_bbox_to_polygon(bbox, crs = 4326)
#> Geometry set for 1 feature 
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 136.8524 ymin: 35.1399 xmax: 136.9524 ymax: 35.1899
#> Geodetic CRS:  WGS 84
#> POLYGON ((136.8524 35.1399, 136.9524 35.1399, 1...
```
