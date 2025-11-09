# Extract road network links

This function extracts the road network links from a set of road
geometries. It splits the road geometries at the nodes and creates a new
sf object representing the road network links.

## Usage

``` r
extract_road_network_links(roads, nodes)
```

## Arguments

- roads:

  A linestring object representing the roads.

- nodes:

  A point object representing the road network nodes.

## Value

A linestring object representing the road network links.

## See also

To create the nodes, use the
[`extract_road_network_nodes()`](https://nononoexe.github.io/pavement/reference/extract_road_network_nodes.md)
