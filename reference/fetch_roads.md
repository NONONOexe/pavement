# Fetch road data from OpenStreetMap

`fetch_roads()` fetches road data from OpenStreetMap. It retrieves roads
within a specified bounding box or within an area defined by a center
point and a radius. Additionally, roads can be cropped to fit within the
specified boundaries.

## Usage

``` r
fetch_roads(x, ...)

# S3 method for class 'matrix'
fetch_roads(x, crop = FALSE, ...)

# S3 method for class 'sfc_POINT'
fetch_roads(x, radius = 15, crop = FALSE, circle_crop = FALSE, ...)

# S3 method for class 'POINT'
fetch_roads(x, radius = 15, crop = FALSE, circle_crop = FALSE, ...)

# S3 method for class 'numeric'
fetch_roads(x, y, radius = 15, crop = FALSE, circle_crop = FALSE, ...)

# S3 method for class 'character'
fetch_roads(x, crop = FALSE, circle_crop = FALSE, ...)
```

## Arguments

- x:

  An object defining the area or location of interest. This can be:

  - A `matrix` representing a bounding box.

  - An `sfc_POINT` or `POINT` object representing a central point.

  - Numeric values representing longitude (`x`) and latitude (`y`).

  - A character string containing a pre-defined Overpass query.

- ...:

  Additional arguments passed to the method.

- crop:

  A logical value indicating whether to crop road data to the specified
  area (default: `FALSE`).

- radius:

  Numeric value representing the search radius in meters (default:
  `15`).

- circle_crop:

  A logical value indicating whether to crop roads within a circular
  area instead of a bounding box (default: `FALSE`). This is only
  effective if `crop = TRUE`.

- y:

  Numeric value representing latitude (required if `x` is numeric and
  represents longitude).

## Value

An `sf` object of class `LINESTRING`, containing road data with the
followings columns:

- id:

  Unique road identifier

- highway:

  Road classification (e.g. "residential", "primary")

- name:

  Road name

- layer:

  Layer information for roads at different elevations

- oneway:

  Logical indicating whether the road is one-way

- osm_id:

  OpenStreetMap unique identifier

## Examples

``` r
if (FALSE) { # \dontrun{
# Define a bounding box
bbox <- create_bbox(north =  35.17377,
                    south =  35.16377,
                    east  = 136.91590,
                    west  = 136.90090)

# Download road data with in the bounding box
roads <- fetch_roads(bbox)

# Plot the roads
plot(roads$geometry)

# Download and crop road data strictly to the bounding box
roads_cropped <- fetch_roads(bbox, crop = TRUE)
plot(roads_cropped$geometry)

# Download roads using a center point and radius
center_lon <- 136.8817
center_lat <-  35.1709
radius_m   <- 500

roads_radius <- fetch_roads(x      = center_lon,
                            y      = center_lat,
                            radius = radius_m)
plot(roads_radius$geometry)
} # }
```
