# Get connected links from a specified node

This function retrieves all links connected to a specified node in a
road network.

## Usage

``` r
get_connected_links(network, node_ids)
```

## Arguments

- network:

  A `road_network` or `segmented_network` object.

- node_ids:

  A vector of node IDs to find connected links for.

## Value

A vector of link IDs connected to the specified node.

## Examples

``` r
# Create a road network
road_network <- create_road_network(sample_roads)
target_node <- road_network$nodes[3,]$id
target_node
#> [1] "jn_000003"

# Get connected links
connected_links <- get_connected_links(road_network, target_node)
connected_links
#> [1] "lk_000002" "lk_000003" "lk_000009" "lk_00000a"

# Plot the target node and the connected links
is_connected <- road_network$links$id %in% connected_links
connected_links_geom <- road_network$links$geometry[is_connected]
plot(road_network, col = "gray")
plot(connected_links_geom, add = TRUE, col = "#E69F00", lwd = 2)
plot(road_network$nodes[3,]$geometry, add = TRUE, pch = 19)
```
