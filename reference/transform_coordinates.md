# Transform to Cartesian or geographic coordinates

This function transforms a spatial object to Cartesian coordinates
(plane rectangular coordinate system) or geographic coordinates (WGS84;
EPSG:4326). The Cartesian system currently supports only Aichi
Prefecture's JDG2011 system (EPSG:6675).

## Usage

``` r
transform_coordinates(
  spatial_object,
  target = c("cartesian", "geographic"),
  quiet = FALSE
)

transform_to_cartesian(spatial_object, quiet = FALSE)

transform_to_geographic(spatial_object, quiet = FALSE)
```

## Arguments

- spatial_object:

  A spatial object.

- target:

  A character string specifying the target coordinate system:
  `"cartesian"` (EPSG:6675) or `"geographic"` (EPSG:4326).

- quiet:

  Logical. If `TRUE`, suppresses the warning when CRS is missing.

## Value

A spatial object transformed to the specified coordinate system.

## Details

If the CRS is missing (NA), a warning is issued, and the original object
is returned. The warning can be suppressed with the `quiet` argument.

## Examples

``` r
# Create points
points <- create_points(136.9024, 35.1649, crs = 4326)
points
#> Geometry set for 1 feature 
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 136.9024 ymin: 35.1649 xmax: 136.9024 ymax: 35.1649
#> Geodetic CRS:  WGS 84
#> POINT (136.9024 35.1649)

# Transform to Cartesian coordinates
transformed <- transform_to_cartesian(points)
transformed
#> Geometry set for 1 feature 
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -24073.54 ymin: -92614.18 xmax: -24073.54 ymax: -92614.18
#> Projected CRS: JGD2011 / Japan Plane Rectangular CS VII
#> POINT (-24073.54 -92614.18)

# Transform to geographic coordinates
transformed <- transform_to_geographic(points)
transformed
#> Geometry set for 1 feature 
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 136.9024 ymin: 35.1649 xmax: 136.9024 ymax: 35.1649
#> Geodetic CRS:  WGS 84
#> POINT (136.9024 35.1649)
```
