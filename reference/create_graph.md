# Create a graph from nodes and links

This function creates a graph object from a set of nodes and links.

## Usage

``` r
create_graph(nodes, links, directed = FALSE)
```

## Arguments

- nodes:

  A `sf` object representing nodes.

- links:

  A `sf` object representing links between nodes.

- directed:

  A logical indicating whether the graph is directed.

## Value

A `igraph` object.

## Examples

``` r
# Create nodes and links
nodes <- extract_road_network_nodes(sample_roads)
links <- extract_road_network_links(sample_roads, nodes)

# Create the graph
graph <- create_graph(nodes, links)
graph
#> IGRAPH 9b2473b UNW- 10 10 -- 
#> + attr: name (v/c), x (v/n), y (v/n), name (e/c), x (e/n), y (e/n),
#> | weight (e/n)
#> + edges from 9b2473b (vertex names):
#>  [1] jn_000001--jn_000002 jn_000003--jn_000005 jn_000003--jn_000004
#>  [4] jn_000006--jn_000006 jn_000002--jn_000006 jn_000007--jn_000008
#>  [7] jn_000002--jn_000007 jn_000007--jn_00000a jn_000003--jn_000009
#> [10] jn_000003--jn_000007

# Plot the graph
plot(graph)
```
