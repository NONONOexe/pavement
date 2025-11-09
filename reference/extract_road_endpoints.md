# Extract road endpoints

This function extracts the endpoints of a set of roads. It identifies
and counts the roads that intersect at each endpoint.

## Usage

``` r
extract_road_endpoints(roads)
```

## Arguments

- roads:

  A linestring object representing roads. It should be have a column
  named `road_id`.

## Value

A points object representing road endpoints. Each endpoint has the
following columns:

- parent_road: A list of road IDs that intersect at the endpoint.

- num_overlaps: The number of roads that intersect at the endpoint.
