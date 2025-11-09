# Extract road network nodes

This function extracts nodes from roads represented as linestring
objects downloaded from OpenStreetMap. Nodes are defined as
intersections between roads and endpoints of road segments.

## Usage

``` r
extract_road_network_nodes(roads)
```

## Arguments

- roads:

  A linestring object representing roads.

## Value

A points object representing road network nodes.
