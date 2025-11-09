# Create processed OpenStreetMap road data for a given area

This is a convenient wrapper function that fetches road data from
OpenStreetMap for a specified bounding box, crops it, and transforms it
to a Cartesian coordinate system for analysis.

## Usage

``` r
create_osm_roads(north, south, east, west)
```

## Arguments

- north:

  The northern latitude of the bounding box (e.g., 35.1886).

- south:

  The southern latitude of the bounding box (e.g., 35.1478).

- east:

  The eastern longitude of the bounding box (e.g., 136.9449).

- west:

  The western longitude of the bounding box (e.g., 136.8736).

## Value

An `sf` object containing the processed road data, ready for use in
functions like
[`create_road_network()`](https://nononoexe.github.io/pavement/reference/road_network.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# Get processed road data for a specific area in Nagoya
nagoya_roads <- create_osm_roads(
  north = 35.1886,
  south = 35.1478,
  east  = 136.9449,
  west  = 136.8736
)
plot(nagoya_roads$geometry)
} # }
```
