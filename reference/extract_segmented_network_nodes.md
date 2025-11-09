# Extract nodes of segmented network from a road network

This function extracts nodes at regular intervals along each link in a
road network

## Usage

``` r
extract_segmented_network_nodes(road_network, segment_length)
```

## Arguments

- road_network:

  A `road_network` object created with `create_network()`.

- segment_length:

  The length of each segment to sample along the links.

## Value

An `sf` object with the sampled points.

## Examples

``` r
# Create a road network
road_network <- create_road_network(sample_roads)

# Extract nodes with a segment length of 1
segmented_network_nodes <- extract_segmented_network_nodes(road_network, 1)
segmented_network_nodes
#> Simple feature collection with 36 features and 3 fields
#> Attribute-geometry relationships: constant (2), NA's (1)
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 7 ymax: 5
#> CRS:           NA
#> First 10 features:
#>             id  parent_link  parent_road                    geometry
#> 1  sn_00000001    lk_000001      rd_0001                 POINT (0 0)
#> 2  sn_00000002 lk_00000.... rd_0001,....                 POINT (4 3)
#> 3  sn_00000003    lk_000001      rd_0001                 POINT (0 0)
#> 4  sn_00000004    lk_000001      rd_0001          POINT (1.027046 0)
#> 5  sn_00000005    lk_000001      rd_0001          POINT (2.054093 0)
#> 6  sn_00000006    lk_000001      rd_0001 POINT (3.025658 0.07697505)
#> 7  sn_00000007    lk_000001      rd_0001   POINT (3.350439 1.051317)
#> 8  sn_00000008    lk_000001      rd_0001   POINT (3.675219 2.025658)
#> 9  sn_00000009 lk_00000.... rd_0002,....                 POINT (6 1)
#> 10 sn_0000000a    lk_000002      rd_0002                 POINT (7 1)

# Plot the segmented network nodes
plot(road_network)
plot(segmented_network_nodes$geometry, add = TRUE, pch = 16, col = "#E69F00")
```
