# Create a road network from roads

This function constructs a road network from a set of roads. The road
network is represented nodes and links between nodes. Nodes are defined
as intersections between roads and endpoints of road segments.

## Usage

``` r
create_road_network(roads, directed = FALSE, events = NULL, ...)
```

## Arguments

- roads:

  A linestring object representing roads.

- directed:

  Logical indicating whether the road network is directed.

- events:

  A `sf` object representing events.

- ...:

  Additional arguments passed to or from other methods.

## Value

A road network object.

## Examples

``` r
# Create the road network
road_network <- create_road_network(sample_roads)

# Print the road network summary
road_network
#> Road network
#> Nodes:
#>          id  parent_road num_overlaps    geometry
#> 1 jn_000001      rd_0001            1 POINT (0 0)
#> 2 jn_000002 rd_0001,....            3 POINT (4 3)
#> 3 jn_000003 rd_0002,....            2 POINT (6 1)
#> 4 jn_000004      rd_0002            1 POINT (0 1)
#> 5 jn_000005      rd_0002            1 POINT (7 1)
#> ... 5 more nodes
#> 
#> Links:
#>          id      from        to parent_road                       geometry
#> 1 lk_000001 jn_000001 jn_000002     rd_0001     LINESTRING (0 0, 3 0, 4 3)
#> 2 lk_000002 jn_000003 jn_000005     rd_0002          LINESTRING (6 1, 7 1)
#> 3 lk_000003 jn_000004 jn_000003     rd_0002          LINESTRING (0 1, 6 1)
#> 4 lk_000004 jn_000006 jn_000006     rd_0003 LINESTRING (2 3, 1 4, 0 3, ...
#> 5 lk_000005 jn_000006 jn_000002     rd_0004          LINESTRING (2 3, 4 3)
#> ... 5 more links

# Plot the road network
plot(road_network)
```
