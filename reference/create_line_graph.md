# Create a line graph from a network

This function creates a line graph where nodes represent the midpoints
of links in the input network.

## Usage

``` r
create_line_graph(network)
```

## Arguments

- network:

  A `road_network` or `segmented_network` object.

## Value

A `igraph` object representing the midpoint graph.

## Examples

``` r
# Create a road network
network <- create_road_network(sample_roads)

# Plot the road network
plot(network$graph)


# Create a midpoint graph from a road network
graph <- create_line_graph(network)

# Plot the midpoint graph
plot(graph)
```
